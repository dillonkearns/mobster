module Setup.Main exposing (main)

import Analytics exposing (trackEvent)
import Animation
import Animation.Messenger
import Break
import Dice
import Dom
import Element exposing (Device)
import Element.Attributes
import GlobalShortcut
import Html exposing (Html)
import Html5.DragDrop as DragDrop
import Ipc
import IpcSerializer
import Json.Decode as Decode
import Json.Encode as Encode
import Keyboard.Combo
import Keyboard.Extra
import Os exposing (Os)
import Page.Break
import Page.Config
import Page.Continue
import Page.Rpg
import QuickRotate
import Random
import Responsive
import Roster.Data as Roster
import Roster.Operation as MobsterOperation exposing (MobsterOperation)
import Roster.Presenter as Presenter
import Setup.InputField as InputField
import Setup.Msg as Msg exposing (Msg)
import Setup.Ports
import Setup.ScreenState as ScreenState exposing (ScreenState)
import Setup.Settings as Settings
import Setup.Shortcuts as Shortcuts
import Setup.Validations as Validations
import Styles
import Task
import Timer.Flags
import Tip
import Update.Extra
import View.FeedbackButton
import View.Navbar
import View.Roster
import View.StartMobbingButton
import View.UpdateAvailable
import Window


shuffleMobstersCmd : Roster.RosterData -> Cmd Msg
shuffleMobstersCmd rosterData =
    Random.generate reorderOperation (Roster.randomizeMobsters rosterData)


type alias DragDropModel =
    DragDrop.Model Msg.DragId Msg.DropArea


changeTip : Cmd Msg
changeTip =
    Random.generate Msg.NewTip Tip.random



-- main view function 15


getInitialWindowSize : Cmd Msg
getInitialWindowSize =
    Window.size
        |> Task.perform Msg.WindowResized


view : Model -> Html Msg
view model =
    Element.column Styles.Main
        [ Element.Attributes.height Element.Attributes.fill ]
        [ View.Navbar.view model
        , Element.column Styles.None
            [ Element.Attributes.paddingXY 110 50
            , Element.Attributes.spacing 30
            ]
            (View.UpdateAvailable.view model.availableUpdateVersion
                :: pageView model
            )
        , View.FeedbackButton.view
        ]
        |> Element.viewport
            (Styles.stylesheet model.device)


pageView : Model -> List Styles.StyleElement
pageView model =
    case model.screenState of
        ScreenState.Configure ->
            Page.Config.view model

        ScreenState.Continue ->
            if Break.breakSuggested model.intervalsSinceBreak model.settings.intervalsPerBreak then
                Page.Break.view model
            else
                Page.Continue.view model

        ScreenState.Rpg rpgState ->
            Page.Rpg.view model rpgState model.settings.rosterData



-- update function helpers 34


resetBreakData :
    { model | secondsSinceBreak : Int, intervalsSinceBreak : Int }
    -> { model | secondsSinceBreak : Int, intervalsSinceBreak : Int }
resetBreakData model =
    { model | secondsSinceBreak = 0, intervalsSinceBreak = 0 }


resetIfAfterBreak :
    { model | secondsSinceBreak : Int, intervalsSinceBreak : Int, settings : Settings.Data }
    -> { model | secondsSinceBreak : Int, intervalsSinceBreak : Int, settings : Settings.Data }
resetIfAfterBreak model =
    let
        timeForBreak =
            Break.breakSuggested model.intervalsSinceBreak model.settings.intervalsPerBreak
    in
    if timeForBreak then
        model |> resetBreakData
    else
        model


saveActiveMobsters :
    ( { model | settings : Settings.Data }, Cmd Msg )
    -> ( { model | settings : Settings.Data }, Cmd Msg )
saveActiveMobsters (( model, msg ) as updateResult) =
    updateResult
        |> withIpcMsg (Ipc.SaveActiveMobstersFile (Roster.currentMobsterNames model.settings.rosterData))


updateSettings :
    (Settings.Data -> Settings.Data)
    -> { model | settings : Settings.Data }
    -> ( { model | settings : Settings.Data }, Cmd Msg )
updateSettings settingsUpdater ({ settings } as model) =
    let
        updatedSettings =
            settingsUpdater settings
    in
    { model | settings = updatedSettings } ! [ Setup.Ports.saveSettings (updatedSettings |> Settings.encoder) ]



-- update function 187


resetKeyboardCombos : ( { model | combos : Keyboard.Combo.Model Msg }, Cmd Msg ) -> ( { model | combos : Keyboard.Combo.Model Msg }, Cmd Msg )
resetKeyboardCombos ( model, cmd ) =
    ( { model | combos = keyboardComboInit }, cmd )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "update" msg of
        Msg.SkipHotkey ->
            case model.screenState of
                ScreenState.Continue ->
                    update (Msg.UpdateRosterData MobsterOperation.NextTurn) model

                _ ->
                    ( model, Cmd.none )

        Msg.StartRpgMode ->
            model ! [] |> changeScreen (ScreenState.Rpg ScreenState.NextUp)

        Msg.StartTimer ->
            (if model.screenState == ScreenState.Continue && Break.breakSuggested model.intervalsSinceBreak model.settings.intervalsPerBreak then
                startBreak model
             else
                case model.screenState of
                    ScreenState.Rpg rpgState ->
                        case rpgState of
                            ScreenState.NextUp ->
                                ( model, Cmd.none )
                                    |> changeScreen (ScreenState.Rpg ScreenState.Checklist)
                                    |> startTimer

                            ScreenState.Checklist ->
                                ( model, Cmd.none )
                                    |> changeScreen (ScreenState.Rpg ScreenState.NextUp)

                    _ ->
                        let
                            nextScreenState =
                                case model.screenState of
                                    ScreenState.Rpg rpgState ->
                                        case rpgState of
                                            ScreenState.Checklist ->
                                                ScreenState.Rpg ScreenState.Checklist

                                            ScreenState.NextUp ->
                                                ScreenState.Rpg ScreenState.NextUp

                                    _ ->
                                        ScreenState.Continue

                            startTimerUpdate =
                                ( model |> resetIfAfterBreak, Cmd.none )
                                    |> changeScreen nextScreenState
                                    |> startTimer
                        in
                        startTimerUpdate
                            |> Update.Extra.andThen update (Msg.UpdateRosterData MobsterOperation.NextTurn)
            )
                |> resetKeyboardCombos

        Msg.SkipBreak ->
            (model |> resetBreakData)
                ! []
                |> changeScreen ScreenState.Continue
                |> Analytics.trackEvent
                    { category = "break"
                    , action = "skip"
                    , label = Just ""
                    , value = Just (toFloat model.secondsSinceBreak / 60.0 |> round)
                    }

        Msg.StartBreak ->
            startBreak model

        Msg.SelectInputField fieldId ->
            model ! [ Setup.Ports.selectDuration fieldId ]

        Msg.OpenConfigure ->
            model
                ! []
                |> changeScreen ScreenState.Configure

        Msg.DomResult _ ->
            model ! []

        Msg.UpdateRosterData operation ->
            model |> performRosterOperation operation

        Msg.ComboMsg comboMsg ->
            let
                ( combos, cmd ) =
                    Keyboard.Combo.update comboMsg model.combos
            in
            ( { model | combos = combos }, cmd )

        Msg.NewTip tipIndex ->
            { model | tip = Tip.get tipIndex } ! []

        Msg.ShuffleMobsters ->
            (model |> Dice.animateRoll |> Dice.animateActiveMobstersShuffle)
                ! []

        Msg.TimeElapsed elapsedSeconds ->
            { model | secondsSinceBreak = model.secondsSinceBreak + elapsedSeconds, intervalsSinceBreak = model.intervalsSinceBreak + 1 } ! []

        Msg.BreakDone elapsedSeconds ->
            model ! []

        Msg.ResetBreakData ->
            (model |> resetBreakData) ! []

        Msg.UpdateAvailable availableUpdateVersion ->
            { model | availableUpdateVersion = Just availableUpdateVersion } ! []

        Msg.RotateOutHotkey index ->
            if rosterViewIsShowing model.screenState then
                performRosterOperation (MobsterOperation.Bench index) model
            else
                model ! []

        Msg.RotateInHotkey index ->
            if rosterViewIsShowing model.screenState then
                update (Msg.UpdateRosterData (MobsterOperation.RotateIn index)) model
            else
                model ! []

        Msg.DragDropMsg dragDropMsg ->
            let
                ( updatedDragDrop, dragDropResult ) =
                    DragDrop.update dragDropMsg model.dragDrop

                updatedModel =
                    { model | dragDrop = updatedDragDrop }
            in
            case dragDropResult of
                Nothing ->
                    updatedModel ! []

                Just ( dragId, dropId ) ->
                    case ( dragId, dropId ) of
                        ( Msg.ActiveMobster id, Msg.DropActiveMobster actualDropid ) ->
                            update (Msg.UpdateRosterData (MobsterOperation.Move id actualDropid)) updatedModel

                        ( Msg.ActiveMobster id, Msg.DropBench ) ->
                            update (Msg.UpdateRosterData (MobsterOperation.Bench id)) updatedModel

                        ( Msg.InactiveMobster inactiveMobsterId, Msg.DropActiveMobster activeMobsterId ) ->
                            update (Msg.UpdateRosterData (MobsterOperation.RotateIn inactiveMobsterId)) updatedModel

                        _ ->
                            updatedModel ! []

        Msg.SendIpc ipcMsg ->
            model ! [ sendIpcCmd ipcMsg ]

        Msg.CheckRpgBox mobster goalIndex ->
            let
                settings =
                    model.settings

                updatedSettings =
                    { settings
                        | rosterData =
                            MobsterOperation.updateMoblist
                                (MobsterOperation.CompleteGoal mobster.index mobster.role goalIndex)
                                model.settings.rosterData
                    }
            in
            ( { model | settings = updatedSettings }, Cmd.none )

        Msg.ViewRpgNextUp ->
            model
                |> performRosterOperationUntracked MobsterOperation.NextTurn
                |> changeScreen (ScreenState.Rpg ScreenState.NextUp)

        Msg.ChangeInput inputField newInputValue ->
            case inputField of
                Msg.StringField stringField ->
                    case stringField of
                        Msg.ShowHideShortcut ->
                            changeGlobalShortcutIfValid newInputValue ( model, Cmd.none )
                                |> trackEvent { category = "configure", action = "change-shortcut", label = Just newInputValue, value = Nothing }

                        Msg.NewMobster ->
                            { model | newMobster = newInputValue } ! []

                        Msg.QuickRotateQuery ->
                            if model.altPressed then
                                model ! []
                            else
                                { model
                                    | quickRotateState =
                                        QuickRotate.update newInputValue
                                            (model.settings.rosterData.inactiveMobsters
                                                |> List.map .name
                                            )
                                            model.quickRotateState
                                }
                                    ! []

                Msg.IntField intField ->
                    let
                        newValueInRange =
                            Validations.parseInputFieldWithinRange intField newInputValue
                    in
                    case intField of
                        InputField.BreakInterval ->
                            model
                                |> updateSettings
                                    (\settings -> { settings | intervalsPerBreak = newValueInRange })
                                |> trackEvent
                                    { category = "settings"
                                    , action = "change-break-interval"
                                    , label = Nothing
                                    , value = Just newValueInRange
                                    }

                        InputField.TimerDuration ->
                            model
                                |> updateSettings
                                    (\settings -> { settings | timerDuration = newValueInRange })
                                |> trackEvent
                                    { category = "settings"
                                    , action = "change-timer-duration"
                                    , label = Nothing
                                    , value = Just newValueInRange
                                    }

                        InputField.BreakDuration ->
                            model
                                |> updateSettings
                                    (\settings -> { settings | breakDuration = newValueInRange })
                                |> trackEvent
                                    { category = "settings"
                                    , action = "change-break-duration"
                                    , label = Nothing
                                    , value = Just newValueInRange
                                    }

        Msg.QuickRotateAdd ->
            case model.quickRotateState.selection of
                QuickRotate.Index benchIndex ->
                    { model | quickRotateState = QuickRotate.init }
                        ! []
                        |> Update.Extra.andThen update
                            (Msg.UpdateRosterData (MobsterOperation.RotateIn benchIndex))

                QuickRotate.All ->
                    model ! []

                QuickRotate.New newMobster ->
                    if View.Roster.preventAddingMobster model.settings.rosterData.mobsters newMobster then
                        model ! []
                    else
                        { model | quickRotateState = QuickRotate.init }
                            ! []
                            |> Update.Extra.andThen update
                                (Msg.UpdateRosterData (MobsterOperation.Add newMobster))

        Msg.QuickRotateMove direction ->
            let
                inactiveMobsterNames =
                    model.settings.rosterData.inactiveMobsters |> List.map .name
            in
            case direction of
                Msg.Next ->
                    { model
                        | quickRotateState = QuickRotate.next inactiveMobsterNames model.quickRotateState
                    }
                        ! []

                Msg.Previous ->
                    { model
                        | quickRotateState = QuickRotate.previous inactiveMobsterNames model.quickRotateState
                    }
                        ! []

        Msg.KeyPressed pressed key ->
            case key of
                Keyboard.Extra.Alt ->
                    { model | altPressed = pressed } ! []

                _ ->
                    model ! []

        Msg.Animate animMsg ->
            let
                ( newMobsterStyle, shuffleCmd ) =
                    Animation.Messenger.update animMsg model.activeMobstersStyle
            in
            { model | dieStyle = Animation.update animMsg model.dieStyle, activeMobstersStyle = newMobsterStyle } ! [ shuffleCmd ]

        Msg.WindowResized windowSize ->
            let
                device =
                    Element.classifyDevice windowSize
            in
            { model
                | device = device
                , responsivePalette = Responsive.palette device
            }
                ! []

        Msg.RandomizeMobsters ->
            model ! [ shuffleMobstersCmd model.settings.rosterData ]

        Msg.OpenContinueScreen ->
            ( model, Cmd.none )
                |> changeScreen ScreenState.Continue


startBreak : Model -> ( Model, Cmd Msg )
startBreak model =
    let
        nextScreenState =
            case model.screenState of
                ScreenState.Rpg _ ->
                    ScreenState.Rpg ScreenState.Checklist

                _ ->
                    ScreenState.Continue
    in
    (model |> resetIfAfterBreak)
        ! [ changeTip ]
        |> changeScreen nextScreenState
        |> startBreakTimer


changeScreen : ScreenState -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
changeScreen newScreenState ( model, cmd ) =
    ( { model | screenState = newScreenState }
    , Cmd.batch
        [ cmd
        , Analytics.trackPage newScreenState
        ]
    )


performRosterOperation :
    MobsterOperation
    -> { model | settings : Settings.Data, screenState : ScreenState, quickRotateState : QuickRotate.State }
    -> ( { model | settings : Settings.Data, screenState : ScreenState, quickRotateState : QuickRotate.State }, Cmd Msg )
performRosterOperation operation model =
    let
        ( updatedModel, cmd ) =
            model
                |> updateSettings
                    (\settings -> { settings | rosterData = MobsterOperation.updateMoblist operation model.settings.rosterData })
                |> saveActiveMobsters
                |> focusQuickRotateInputIfVisible
    in
    ( updatedModel, cmd )
        |> Analytics.trackOperation operation


performRosterOperationUntracked :
    MobsterOperation
    -> { model | settings : Settings.Data, screenState : ScreenState, quickRotateState : QuickRotate.State }
    -> ( { model | settings : Settings.Data, screenState : ScreenState, quickRotateState : QuickRotate.State }, Cmd Msg )
performRosterOperationUntracked operation model =
    let
        ( updatedModel, cmd ) =
            model
                |> updateSettings
                    (\settings -> { settings | rosterData = MobsterOperation.updateMoblist operation model.settings.rosterData })
                |> saveActiveMobsters
                |> focusQuickRotateInputIfVisible
    in
    ( updatedModel, cmd )


changeGlobalShortcutIfValid : String -> ( { model | settings : Settings.Data }, Cmd Msg ) -> ( { model | settings : Settings.Data }, Cmd Msg )
changeGlobalShortcutIfValid newInputValue ( model, cmd ) =
    if GlobalShortcut.isInvalid newInputValue then
        model ! []
    else
        let
            shortcutString =
                if newInputValue == "" then
                    ""
                else
                    "CommandOrControl+Shift+" ++ newInputValue
        in
        (model
            |> updateSettings
                (\settings -> { settings | showHideShortcut = newInputValue })
        )
            |> Update.Extra.addCmd cmd
            |> withIpcMsg (Ipc.ChangeShortcut shortcutString)


sendIpcCmd : Ipc.Msg -> Cmd msg
sendIpcCmd ipcMsg =
    ipcMsg
        |> IpcSerializer.serialize
        |> Setup.Ports.sendIpc


withIpcMsg : Ipc.Msg -> ( model, Cmd Msg ) -> ( model, Cmd Msg )
withIpcMsg msgIpc ( model, cmd ) =
    model ! [ cmd, sendIpcCmd msgIpc ]


startTimer : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
startTimer (( model, cmd ) as msgAndCmd) =
    msgAndCmd
        |> withIpcMsg (Ipc.StartTimer (timerFlags model.settings))
        |> Update.Extra.addCmd (Cmd.batch [ changeTip, blurContinueButton ])
        |> Analytics.trackEvent
            { category = "stats"
            , action = "active-mobsters"
            , label = Nothing
            , value =
                model.settings.rosterData.mobsters
                    |> List.length
                    |> Just
            }
        |> Analytics.trackEvent
            { category = "stats"
            , action = "inactive-mobsters"
            , label = Nothing
            , value =
                model.settings.rosterData.inactiveMobsters
                    |> List.length
                    |> Just
            }


timerFlags : Settings.Data -> Encode.Value
timerFlags settings =
    let
        { driver, navigator } =
            Presenter.nextDriverNavigator settings.rosterData
    in
    Timer.Flags.encodeRegularTimer
        { minutes = settings.timerDuration
        , driver = driver.name
        , navigator = navigator.name
        }


startBreakTimer : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
startBreakTimer (( model, cmd ) as msgAndCmd) =
    msgAndCmd |> withIpcMsg (Ipc.StartTimer (Timer.Flags.encodeBreak model.settings.breakDuration))


rosterViewIsShowing : ScreenState -> Bool
rosterViewIsShowing screenState =
    screenState == ScreenState.Configure


keyboardComboInit : Keyboard.Combo.Model Msg
keyboardComboInit =
    Keyboard.Combo.init
        { toMsg = Msg.ComboMsg
        , combos = Shortcuts.keyboardCombos
        }


focusQuickRotateInput : Cmd Msg
focusQuickRotateInput =
    quickRotateQueryId
        |> Dom.focus
        |> Task.attempt Msg.DomResult


focusQuickRotateInputIfVisible : ( { model | screenState : ScreenState }, Cmd Msg ) -> ( { model | screenState : ScreenState }, Cmd Msg )
focusQuickRotateInputIfVisible (( model, cmd ) as updateResult) =
    if model.screenState == ScreenState.Configure then
        model ! [ cmd, focusQuickRotateInput ]
    else
        updateResult


quickRotateQueryId : String
quickRotateQueryId =
    "quick-rotate-query"


reorderOperation : List Roster.Mobster -> Msg
reorderOperation shuffledMobsters =
    Msg.UpdateRosterData (MobsterOperation.Reorder shuffledMobsters)


blurContinueButton : Cmd Msg
blurContinueButton =
    View.StartMobbingButton.buttonId
        |> Dom.blur
        |> Task.attempt Msg.DomResult



-- elm boilerplate 73


type alias Flags =
    { onMac : Bool
    , isLocal : Bool
    , settings : Decode.Value
    }


init : Flags -> ( Model, Cmd Msg )
init { onMac, isLocal, settings } =
    let
        decodedSettings =
            Settings.decode settings

        maybeDecodeError =
            case decodedSettings of
                Ok _ ->
                    Nothing

                Err errorString ->
                    if isLocal then
                        Debug.crash ("init failed to decode settings:\n" ++ errorString)
                    else
                        Just errorString

        initialSettings =
            decodedSettings
                |> Result.withDefault Nothing
                |> Maybe.withDefault Settings.initial

        notifyIfDecodeFailed =
            case maybeDecodeError of
                Just errorString ->
                    sendIpcCmd (Ipc.NotifySettingsDecodeFailed errorString)

                Nothing ->
                    Cmd.none
    in
    initialModel initialSettings onMac
        ! [ notifyIfDecodeFailed, getInitialWindowSize, changeTip ]
        |> saveActiveMobsters
        |> changeGlobalShortcutIfValid initialSettings.showHideShortcut


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Keyboard.Combo.subscriptions model.combos
        , Setup.Ports.timeElapsed Msg.TimeElapsed
        , Setup.Ports.breakDone Msg.BreakDone
        , Setup.Ports.updateDownloaded Msg.UpdateAvailable
        , Keyboard.Extra.downs (Msg.KeyPressed True)
        , Keyboard.Extra.ups (Msg.KeyPressed False)
        , Animation.subscription Msg.Animate [ model.dieStyle ]
        , Animation.subscription Msg.Animate [ model.activeMobstersStyle ]
        , Window.resizes Msg.WindowResized
        ]


type alias Model =
    { settings : Settings.Data
    , screenState : ScreenState
    , newMobster : String
    , combos : Keyboard.Combo.Model Msg
    , tip : Tip.Tip
    , secondsSinceBreak : Int
    , intervalsSinceBreak : Int
    , availableUpdateVersion : Maybe String
    , dragDrop : DragDropModel
    , os : Os
    , quickRotateState : QuickRotate.State
    , altPressed : Bool
    , dieStyle : Animation.State
    , activeMobstersStyle : Animation.Messenger.State Msg.Msg
    , device : Device
    , responsivePalette : Responsive.Palette
    }


initialModel : Settings.Data -> Bool -> Model
initialModel settings onMac =
    let
        os =
            if onMac then
                Os.Mac
            else
                Os.NotMac
    in
    { settings = settings
    , screenState = ScreenState.Configure
    , newMobster = ""
    , combos = keyboardComboInit
    , tip = Tip.emptyTip
    , secondsSinceBreak = 0
    , intervalsSinceBreak = 0
    , availableUpdateVersion = Nothing
    , dragDrop = DragDrop.init
    , os = os
    , quickRotateState = QuickRotate.init
    , altPressed = False
    , dieStyle = Animation.style [ Animation.rotate (Animation.turn 0.0) ]
    , activeMobstersStyle = Animation.style [ Animation.opacity 1 ]
    , device = Element.Device 0 0 False False False False False
    , responsivePalette = Responsive.defaultPalette
    }


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
