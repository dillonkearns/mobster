module Setup.Main exposing (main)

import Animation exposing (Step)
import Animation.Messenger
import Basics.Extra exposing ((=>))
import Bootstrap
import Break
import Dice
import Dom
import Element exposing (Device)
import Element.Attributes
import FA
import GlobalShortcut
import Html exposing (..)
import Html.Attributes as Attr exposing (placeholder, src, style, target, title, type_, value)
import Html.Events exposing (keyCode, on, onCheck, onClick, onFocus, onInput, onSubmit)
import Html5.DragDrop as DragDrop
import Ipc
import IpcSerializer
import Json.Decode as Decode
import Json.Encode as Encode
import Keyboard.Combo
import Keyboard.Extra
import Page.Continue
import Pages.Break
import QuickRotate
import Random
import Roster.Data as Roster
import Roster.Operation as MobsterOperation exposing (MobsterOperation)
import Roster.Presenter as Presenter
import Setup.Forms.ViewHelpers
import Setup.InputField exposing (IntInputField(..))
import Setup.Msg as Msg exposing (Msg)
import Setup.Navbar as Navbar
import Setup.Ports
import Setup.Rpg.View exposing (RpgState(..))
import Setup.Settings as Settings
import Setup.Shortcuts as Shortcuts
import Setup.Validations as Validations
import Setup.View exposing (..)
import Styles
import StylesheetHelper exposing (CssClasses(..), class, classList, id)
import Task
import Timer.Flags
import Tip
import Update.Extra
import View.Break
import View.IntervalsToBreak
import View.Navbar
import View.Roster
import View.Tip
import View.UpdateAvailable
import ViewHelpers
import Window


shuffleMobstersCmd : Roster.RosterData -> Cmd Msg
shuffleMobstersCmd rosterData =
    Random.generate reorderOperation (Roster.randomizeMobsters rosterData)


type alias DragDropModel =
    DragDrop.Model Msg.DragId Msg.DropArea


changeTip : Cmd Msg
changeTip =
    Random.generate Msg.NewTip Tip.random



-- cross-page view stuff 37


feedbackButton : Html Msg
feedbackButton =
    div []
        [ a [ onClick <| Msg.SendIpc Ipc.ShowFeedbackForm, style [ "text-transform" => "uppercase", "transform" => "rotate(-90deg)" ], Attr.tabindex -1, Attr.class "btn btn-sm btn-default pull-right", Attr.id "feedback" ] [ span [ class [ BufferRight ] ] [ text "Feedback" ], span [ Attr.class "fa fa-comment-o" ] [] ] ]


ctrlKey : Bool -> String
ctrlKey onMac =
    if onMac then
        "⌘"
    else
        "Ctrl"


startMobbingShortcut : Bool -> String
startMobbingShortcut onMac =
    ctrlKey onMac ++ "+Enter"



-- continue view 92


continueView : Bool -> Model -> Html Msg
continueView showRotation model =
    let
        mainView =
            if showRotation then
                div []
                    [ View.Roster.rotationView model.dragDrop model.quickRotateState model.settings.rosterData model.activeMobstersStyle (Animation.render model.dieStyle)
                    , button [ style [ "margin-bottom" => "12px" ], Attr.class "btn btn-small btn-default pull-right", onClick Msg.ToggleRotationScreen ]
                        [ span [ class [ BufferRight ] ] [ text "Back to tip view" ], span [ Attr.class "fa fa-arrow-circle-o-left" ] [] ]
                    ]
            else
                div []
                    [ table [ Attr.class "table table-hover" ] [ tbody [] [ View.Roster.newMobsterRowView False model.quickRotateState False ] ]
                    , View.Tip.view model.tip
                    ]
    in
    if Break.breakSuggested model.intervalsSinceBreak model.settings.intervalsPerBreak then
        View.Break.view model
    else
        div [ Attr.class "container-fluid" ]
            [ View.IntervalsToBreak.view model.intervalsSinceBreak model.settings.intervalsPerBreak
            , nextDriverNavigatorView model
            , div [ class [ BufferTop ] ] [ mainView ]
            , ViewHelpers.blockButton "Continue" Msg.StartTimer (startMobbingShortcut model.onMac |> Just) continueButtonId
            ]


nextDriverNavigatorView : Model -> Html Msg
nextDriverNavigatorView model =
    let
        driverNavigator =
            Presenter.nextDriverNavigator model.settings.rosterData

        fastForwardButton =
            div [ Attr.class "col-md-1 col-sm-1 text-default" ]
                [ span [ Attr.class "btn btn-sm btn-default btn-block", style [ "font-size" => "23px", "padding-right" => "4px" ], class [ ShowOnParentHover ], onClick <| Msg.UpdateRosterData MobsterOperation.NextTurn ]
                    [ span [ Attr.class "fa fa-fast-forward text-warning" ] []
                    ]
                ]

        rewindButton =
            div [ Attr.class "col-md-1 col-sm-1 text-default" ]
                [ span [ Attr.class "btn btn-sm btn-default btn-block", style [ "font-size" => "23px", "padding-right" => "4px" ], class [ ShowOnParentHover ], onClick <| Msg.UpdateRosterData MobsterOperation.RewindTurn ]
                    [ span [ Attr.class "fa fa-fast-backward text-warning" ] []
                    ]
                ]
    in
    div [ Attr.class "row h1 text-center", class [ ShowOnParentHoverParent, HasHoverActions ] ]
        [ rewindButton
        , dnView driverNavigator.driver Presenter.Driver
        , dnView driverNavigator.navigator Presenter.Navigator
        , fastForwardButton
        ]


dnView : Presenter.Mobster -> Presenter.Role -> Html Msg
dnView mobster role =
    let
        icon =
            case role of
                Presenter.Driver ->
                    "./assets/driver-icon.png"

                Presenter.Navigator ->
                    "./assets/navigator-icon.png"

        awayButton =
            span
                [ Attr.class "btn btn-sm btn-default"
                , style [ "font-size" => "23px" ]
                , class [ ShowOnParentHover, BufferRight ]
                , onClick <| Msg.UpdateRosterData (MobsterOperation.Bench mobster.index)
                ]
                [ span [ Attr.class "fa fa-user-times text-danger", style [ "padding-right" => "4px" ] ] []
                , text " Away"
                ]
    in
    div [ Attr.class "col-md-5 col-sm-5 text-default" ]
        [ iconView icon 60
        , span [ class [ BufferRight ] ] [ text mobster.name ]
        , span [] [ awayButton ]
        ]



-- view helpers (used across pages) 14


iconView : String -> Int -> Html msg
iconView iconUrl maxWidth =
    img [ style [ "max-width" => (toString maxWidth ++ "px"), "margin-right" => "0.533em" ], src iconUrl ] []


nextView : String -> String -> Html msg
nextView thing name =
    span []
        [ span [ Attr.class "text-muted" ] [ text ("Next " ++ thing ++ ": ") ]
        , span [ Attr.class "text-info" ] [ text name ]
        ]


configureView : Model -> Html Msg
configureView model =
    div [ Attr.class "container-fluid" ]
        [ div [ Attr.class "row" ]
            [ div [ Attr.class "col-md-4 col-sm-12" ]
                [ timerDurationInputView model.settings.timerDuration
                , breakIntervalInputView model.settings.intervalsPerBreak model.settings.timerDuration
                , breakDurationInputView model.settings.breakDuration
                , shortcutInputView model.settings.showHideShortcut model.onMac
                ]
            , div [ Attr.class "col-md-8 col-sm-12" ] [ View.Roster.rotationView model.dragDrop model.quickRotateState model.settings.rosterData model.activeMobstersStyle (Animation.render model.dieStyle) ]
            ]
        , div []
            [ h3 [] [ text "Getting Started" ]
            , Bootstrap.smallButton "Install Mob Git Commit Script" (Msg.SendIpc Ipc.ShowScriptInstallInstructions) Bootstrap.Primary FA.Github
            , Bootstrap.smallButton "Learn to Mob Game" Msg.StartRpgMode Bootstrap.Success FA.Gamepad
            ]
        , div [ style [ "margin-top" => "50px" ] ] [ ViewHelpers.blockButton "Start Mobbing" Msg.StartTimer (startMobbingShortcut model.onMac |> Just) continueButtonId ]
        ]



-- configure inputs (Settings -> Html Msg) 46


timerDurationInputView : Int -> Html Msg
timerDurationInputView duration =
    div [ Attr.class "text-primary h3 col-md-12 col-sm-6", style [ "margin-top" => "0px" ] ]
        [ Setup.Forms.ViewHelpers.intInputView TimerDuration duration
        , text "Minutes"
        ]


breakDurationInputView : Int -> Html Msg
breakDurationInputView duration =
    div [ Attr.class "text-primary h3 col-md-12 col-sm-6", style [ "margin-top" => "0px" ] ]
        [ Setup.Forms.ViewHelpers.intInputView BreakDuration duration
        , text "Minutes Per Break"
        ]


breakIntervalInputView : Int -> Int -> Html Msg
breakIntervalInputView intervalsPerBreak timerDuration =
    let
        theString =
            if intervalsPerBreak > 0 then
                "Break every " ++ toString (intervalsPerBreak * timerDuration) ++ "′"
            else
                "Breaks off"
    in
    div [ Attr.class "text-primary h3 col-md-12 col-sm-6", style [ "margin-top" => "0px" ] ]
        [ Setup.Forms.ViewHelpers.intInputView BreakInterval intervalsPerBreak
        , text theString
        ]


shortcutInputView : String -> Bool -> Html Msg
shortcutInputView currentShortcut onMac =
    div [ Attr.class "text-primary h3 col-md-12 col-sm-6", style [ "margin-top" => "0px" ] ]
        [ text "Show/Hide: "
        , text (ctrlKey onMac ++ "+shift+")
        , input
            [ id "shortcut"
            , onInput (Msg.ChangeInput (Msg.StringField Msg.ShowHideShortcut))
            , class [ BufferRight ]
            , value currentShortcut
            , style [ "font-size" => "4.0rem", "width" => "40px" ]
            , Attr.maxlength 1
            ]
            []
        ]



-- main view function 15


getInitialWindowSize : Cmd Msg
getInitialWindowSize =
    Window.size
        |> Task.perform Msg.WindowResized


view : Model -> Html Msg
view model =
    let
        mainView =
            case model.screenState of
                Configure ->
                    configureView model

                Continue showRotation ->
                    continueView showRotation model

                Rpg rpgState ->
                    Setup.Rpg.View.rpgView rpgState model.settings.rosterData
    in
    if model.showBetaUi && model.screenState == Configure then
        styleElementsConfigureView model (configureBetaViewElements model)
    else if model.showBetaUi && (model.screenState == Continue True || model.screenState == Continue False) then
        styleElementsConfigureView model <|
            if Break.breakSuggested model.intervalsSinceBreak model.settings.intervalsPerBreak then
                Pages.Break.view model
            else
                Page.Continue.view model
    else
        div [] [ Navbar.view model.screenState, View.UpdateAvailable.view model.availableUpdateVersion, mainView, feedbackButton ]


styleElementsConfigureView : Model -> List Styles.StyleElement -> Html Msg
styleElementsConfigureView model bodyElements =
    Element.viewport (Styles.stylesheet model.device) <|
        Element.column Styles.Main
            [ Element.Attributes.height (Element.Attributes.fill 1) ]
            [ View.Navbar.view model
            , Element.column Styles.None
                [ Element.Attributes.paddingXY 110 50, Element.Attributes.spacing 30, Element.Attributes.height (Element.Attributes.fill 1) ]
                bodyElements
            ]


configureBetaViewElements : Model -> List Styles.StyleElement
configureBetaViewElements model =
    [ Element.row Styles.None
        [ Element.Attributes.spacing 50 ]
        [ Styles.configOptions model.onMac model.settings
        , Element.el Styles.None [ Element.Attributes.width (Element.Attributes.fill 1) ] <|
            Element.html
                (View.Roster.rotationView model.dragDrop model.quickRotateState model.settings.rosterData model.activeMobstersStyle (Animation.render model.dieStyle))
        ]
    , Styles.startMobbingButton model.onMac "Start Mobbing"
    ]



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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "update" msg of
        Msg.SkipHotkey ->
            case model.screenState of
                Continue showRotation ->
                    update (Msg.UpdateRosterData MobsterOperation.NextTurn) model

                _ ->
                    model ! []

        Msg.StartRpgMode ->
            { model | screenState = Rpg NextUp } ! []

        Msg.ToggleRotationScreen ->
            case model.screenState of
                Continue showRotation ->
                    let
                        sideEffects =
                            if showRotation then
                                []
                            else
                                [ focusQuickRotateInput ]
                    in
                    { model | screenState = Continue (not showRotation) } ! sideEffects

                Configure ->
                    model ! [ focusQuickRotateInput ]

                _ ->
                    model ! []

        Msg.ShowRotationScreen ->
            case model.screenState of
                Continue showRotation ->
                    { model | screenState = Continue True } ! [ focusQuickRotateInput ]

                Configure ->
                    model ! [ focusQuickRotateInput ]

                _ ->
                    model ! []

        Msg.StartTimer ->
            if model.screenState == Continue False && Break.breakSuggested model.intervalsSinceBreak model.settings.intervalsPerBreak then
                startBreak model
            else
                let
                    nextScreenState =
                        case model.screenState of
                            Rpg rpgState ->
                                Rpg Checklist

                            _ ->
                                Continue False

                    updatedModel =
                        { model
                            | screenState = nextScreenState
                            , combos = keyboardComboInit
                        }
                            |> resetIfAfterBreak

                    startTimerUpdate =
                        updatedModel
                            ! [ changeTip, blurContinueButton ]
                            |> startTimer
                in
                case model.screenState of
                    Rpg rpgState ->
                        startTimerUpdate

                    _ ->
                        startTimerUpdate |> Update.Extra.andThen update (Msg.UpdateRosterData MobsterOperation.NextTurn)

        Msg.SkipBreak ->
            let
                updatedModel =
                    { model | screenState = Continue False }
                        |> resetBreakData
            in
            updatedModel ! []

        Msg.StartBreak ->
            startBreak model

        Msg.SelectInputField fieldId ->
            model ! [ Setup.Ports.selectDuration fieldId ]

        Msg.OpenConfigure ->
            { model | screenState = Configure } ! []

        Msg.AddMobster ->
            if model.newMobster == "" || Roster.containsName model.newMobster model.settings.rosterData then
                model ! []
            else
                update (Msg.UpdateRosterData (MobsterOperation.Add model.newMobster)) { model | newMobster = "" }

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

        Msg.EnterRating rating ->
            update Msg.StartTimer { model | ratings = model.ratings ++ [ rating ] }

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
                            model ! []

        Msg.SendIpc ipcMsg ->
            model ! [ sendIpcCmd ipcMsg ]

        Msg.CheckRpgBox msg checkedValue ->
            update msg model

        Msg.ViewRpgNextUp ->
            { model | screenState = Rpg NextUp }
                ! []
                |> Update.Extra.andThen update
                    (Msg.UpdateRosterData MobsterOperation.NextTurn)

        Msg.ChangeInput inputField newInputValue ->
            case inputField of
                Msg.StringField stringField ->
                    case stringField of
                        Msg.ShowHideShortcut ->
                            changeGlobalShortcutIfValid model newInputValue

                        Msg.NewMobster ->
                            { model | newMobster = newInputValue } ! []

                        Msg.QuickRotateQuery ->
                            if model.altPressed then
                                model ! []
                            else
                                { model | quickRotateState = QuickRotate.update newInputValue (model.settings.rosterData.inactiveMobsters |> List.map .name) model.quickRotateState } ! []

                Msg.IntField intField ->
                    let
                        newValueInRange =
                            Validations.parseInputFieldWithinRange intField newInputValue
                    in
                    case intField of
                        BreakInterval ->
                            model
                                |> updateSettings
                                    (\settings -> { settings | intervalsPerBreak = newValueInRange })

                        TimerDuration ->
                            model
                                |> updateSettings
                                    (\settings -> { settings | timerDuration = newValueInRange })

                        BreakDuration ->
                            model
                                |> updateSettings
                                    (\settings -> { settings | breakDuration = newValueInRange })

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
            { model | device = Element.classifyDevice windowSize } ! []

        Msg.ToggleBetaUi ->
            { model | showBetaUi = not model.showBetaUi } ! []

        Msg.RandomizeMobsters ->
            model ! [ shuffleMobstersCmd model.settings.rosterData ]


startBreak : Model -> ( Model, Cmd Msg )
startBreak model =
    let
        nextScreenState =
            case model.screenState of
                Rpg _ ->
                    Rpg Checklist

                _ ->
                    Continue False

        updatedModel =
            { model | screenState = nextScreenState }
                |> resetIfAfterBreak
    in
    updatedModel
        ! [ changeTip ]
        |> startBreakTimer


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
    ( updatedModel |> updateQuickRotateStateIfActive, cmd )


changeGlobalShortcutIfValid : { model | settings : Settings.Data } -> String -> ( { model | settings : Settings.Data }, Cmd Msg )
changeGlobalShortcutIfValid model newInputValue =
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
        model
            |> updateSettings
                (\settings -> { settings | showHideShortcut = newInputValue })
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
    msgAndCmd |> withIpcMsg (Ipc.StartTimer (timerFlags model.settings))


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
    screenState == Continue True || screenState == Configure


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
    if model.screenState == Continue True then
        model ! [ cmd, focusQuickRotateInput ]
    else
        updateResult


updateQuickRotateStateIfActive :
    { model | screenState : ScreenState, settings : Settings.Data, quickRotateState : QuickRotate.State }
    -> { model | screenState : ScreenState, settings : Settings.Data, quickRotateState : QuickRotate.State }
updateQuickRotateStateIfActive model =
    if model.screenState == Continue True then
        { model | quickRotateState = QuickRotate.update model.quickRotateState.query (model.settings.rosterData.inactiveMobsters |> List.map .name) model.quickRotateState }
    else
        model


quickRotateQueryId : String
quickRotateQueryId =
    "quick-rotate-query"


reorderOperation : List Roster.Mobster -> Msg
reorderOperation shuffledMobsters =
    Msg.UpdateRosterData (MobsterOperation.Reorder shuffledMobsters)


blurContinueButton : Cmd Msg
blurContinueButton =
    continueButtonId
        |> Dom.blur
        |> Task.attempt Msg.DomResult


continueButtonId : String
continueButtonId =
    "continue-button"



-- elm boilerplate 73


type alias Flags =
    { onMac : Bool, isLocal : Bool, settings : Decode.Value }


init : Flags -> ( Model, Cmd Msg )
init { onMac, isLocal, settings } =
    let
        decodedSettings =
            Settings.decode settings

        ( initialSettings, maybeDecodeError ) =
            case decodedSettings of
                Ok settings ->
                    ( settings, Nothing )

                Err errorString ->
                    if isLocal then
                        Debug.crash ("init failed to decode settings:\n" ++ errorString)
                    else
                        ( Settings.initial, Just errorString )

        notifyIfDecodeFailed =
            case maybeDecodeError of
                Just errorString ->
                    sendIpcCmd (Ipc.NotifySettingsDecodeFailed errorString)

                Nothing ->
                    Cmd.none
    in
    initialModel initialSettings onMac
        ! [ notifyIfDecodeFailed, getInitialWindowSize ]
        |> saveActiveMobsters
        |> Update.Extra.andThen update
            (Msg.ChangeInput (Msg.StringField Msg.ShowHideShortcut) initialSettings.showHideShortcut)


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
    , ratings : List Int
    , secondsSinceBreak : Int
    , intervalsSinceBreak : Int
    , availableUpdateVersion : Maybe String
    , dragDrop : DragDropModel
    , onMac : Bool
    , quickRotateState : QuickRotate.State
    , altPressed : Bool
    , dieStyle : Animation.State
    , activeMobstersStyle : Animation.Messenger.State Msg.Msg
    , device : Device
    , showBetaUi : Bool
    }


initialModel : Settings.Data -> Bool -> Model
initialModel settings onMac =
    { settings = settings
    , screenState = Configure
    , newMobster = ""
    , combos = keyboardComboInit
    , tip = Tip.emptyTip
    , ratings = []
    , secondsSinceBreak = 0
    , intervalsSinceBreak = 0
    , availableUpdateVersion = Nothing
    , dragDrop = DragDrop.init
    , onMac = onMac
    , quickRotateState = QuickRotate.init
    , altPressed = False
    , dieStyle = Animation.style [ Animation.rotate (Animation.turn 0.0) ]
    , activeMobstersStyle = Animation.style [ Animation.opacity 1 ]
    , device = Element.Device 0 0 False False False False False
    , showBetaUi = False
    }


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
