module Setup.Main exposing (main)

import Animation exposing (Step)
import Basics.Extra exposing ((=>))
import Bootstrap
import Break
import Dice
import Dom
import FA
import GlobalShortcut
import Html exposing (..)
import Html.Attributes as Attr exposing (id, placeholder, src, style, target, title, type_, value)
import Html.CssHelpers
import Html.Events exposing (keyCode, on, onCheck, onClick, onFocus, onInput, onSubmit)
import Html5.DragDrop as DragDrop
import Ipc
import Json.Decode as Decode
import Json.Encode as Encode
import Keyboard.Combo
import Keyboard.Extra
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
import Setup.RosterView as RosterView
import Setup.Rpg.View exposing (RpgState(..))
import Setup.Settings as Settings
import Setup.Shortcuts as Shortcuts
import Setup.Stylesheet exposing (CssClasses(..))
import Setup.Validations as Validations
import Setup.View exposing (..)
import Task
import Timer.Flags
import Tip
import Update.Extra


{ id, class, classList } =
    Html.CssHelpers.withNamespace "setup"


shuffleMobstersCmd : Roster.RosterData -> Cmd Msg
shuffleMobstersCmd rosterData =
    Random.generate reorderOperation (Roster.randomizeMobsters rosterData)


type alias DragDropModel =
    DragDrop.Model Msg.DragId Msg.DropArea


changeTip : Cmd Msg
changeTip =
    Random.generate Msg.NewTip Tip.random


startTimerFlags : Bool -> { model | settings : Settings.Data } -> Encode.Value
startTimerFlags isBreak model =
    let
        { driver, navigator } =
            Presenter.nextDriverNavigator model.settings.rosterData

        minutes =
            if isBreak then
                model.settings.breakDuration
            else
                model.settings.timerDuration
    in
    Timer.Flags.encode
        { minutes = minutes
        , driver = driver.name
        , navigator = navigator.name
        , isBreak = isBreak
        }



-- cross-page view stuff 57


updateAvailableView : Maybe String -> Html Msg
updateAvailableView availableUpdateVersion =
    case availableUpdateVersion of
        Nothing ->
            div [] []

        Just version ->
            div [ Attr.class "alert alert-success" ]
                [ span [ Attr.class "glyphicon glyphicon-flag", class [ BufferRight ] ] []
                , text "A new version is downloaded and ready to install. "
                , a [ onClick <| Msg.SendIpc Ipc.QuitAndInstall Encode.null, Attr.href "#", Attr.class "alert-link", class [ HandPointer ] ] [ text "Update now" ]
                , text "."
                ]


feedbackButton : Html Msg
feedbackButton =
    div []
        [ a [ onClick <| Msg.SendIpc Ipc.ShowFeedbackForm Encode.null, style [ "text-transform" => "uppercase", "transform" => "rotate(-90deg)" ], Attr.tabindex -1, Attr.class "btn btn-sm btn-default pull-right", Attr.id "feedback" ] [ span [ class [ BufferRight ] ] [ text "Feedback" ], span [ Attr.class "fa fa-comment-o" ] [] ] ]


ctrlKey : Bool -> String
ctrlKey onMac =
    if onMac then
        "⌘"
    else
        "Ctrl"



-- shortcuts 3


startMobbingShortcut : Bool -> String
startMobbingShortcut onMac =
    ctrlKey onMac ++ "+Enter"



-- breaks 31


viewIntervalsBeforeBreak : Model -> Html Msg
viewIntervalsBeforeBreak model =
    let
        remainingIntervals =
            Break.timersBeforeNext model.intervalsSinceBreak model.settings.intervalsPerBreak

        intervalBadges =
            List.range 1 model.settings.intervalsPerBreak
                |> List.map (\index -> index > model.intervalsSinceBreak)
                |> List.map
                    (\grayBadge ->
                        if grayBadge then
                            span [ Attr.class "label label-default" ] [ text " " ]
                        else
                            span [ Attr.class "label label-info" ] [ text " " ]
                    )
    in
    div [ onClick Msg.ResetBreakData ] intervalBadges



-- continue view 92


continueButtonId : String
continueButtonId =
    "continue-button"


continueButtons : Model -> Html Msg
continueButtons model =
    div [ Attr.class "row", style [ "padding-bottom" => "1.333em" ] ]
        [ button
            [ noTab
            , onClick Msg.StartTimer
            , Attr.class "btn btn-info btn-lg btn-block"
            , class [ LargeButtonText, BufferTop, TooltipContainer ]
            , Attr.id continueButtonId
            ]
            [ div [] [ text "Continue" ]
            , div [ class [ Tooltip ] ] [ text (startMobbingShortcut model.onMac) ]
            ]
        ]


continueView : Bool -> Model -> Html Msg
continueView showRotation model =
    let
        mainView =
            if showRotation then
                div []
                    [ RosterView.rotationView model.dragDrop model.quickRotateState model.settings.rosterData model.activeMobstersStyle (Animation.render model.dieStyle)
                    , button [ style [ "margin-bottom" => "12px" ], Attr.class "btn btn-small btn-default pull-right", onClick Msg.ShowRotationScreen ]
                        [ span [ class [ BufferRight ] ] [ text "Back to tip view" ], span [ Attr.class "fa fa-arrow-circle-o-left" ] [] ]
                    ]
            else
                div []
                    [ table [ Attr.class "table table-hover" ] [ tbody [] [ RosterView.newMobsterRowView False model.quickRotateState False ] ]
                    , tipView model.tip
                    ]
    in
    if Break.breakSuggested model.intervalsSinceBreak model.settings.intervalsPerBreak then
        breakView model
    else
        div [ Attr.class "container-fluid" ]
            [ viewIntervalsBeforeBreak model
            , nextDriverNavigatorView model
            , div [ class [ BufferTop ] ] [ mainView ]
            , continueButtons model
            ]


breakButtonsView : Html Msg
breakButtonsView =
    div [ Attr.class "row", style [ "padding-bottom" => "1.333em" ] ]
        [ div [ Attr.class "col-md-3" ]
            [ button
                [ noTab
                , onClick Msg.SkipBreak
                , Attr.class "btn btn-default btn-lg btn-block"
                , class [ LargeButtonText, BufferTop, BufferRight, TooltipContainer, ButtonMuted ]
                ]
                [ span [] [ text "Skip Break" ] ]
            ]
        , div [ Attr.class "col-md-9" ]
            [ button
                [ noTab
                , onClick Msg.StartBreak
                , Attr.class "btn btn-success btn-lg btn-block"
                , class [ LargeButtonText, BufferTop, TooltipContainer ]
                ]
                [ span [ class [ BufferRight ] ] [ text "Take a Break" ], i [ Attr.class "fa fa-coffee" ] [] ]
            ]
        ]


breakView : Model -> Html Msg
breakView model =
    div [ Attr.class "container-fluid" ]
        [ breakAlertView model.secondsSinceBreak
        , div [ class [ BufferTop ] ] [ tipView model.tip ]
        , breakButtonsView
        ]


breakAlertView : Int -> Html msg
breakAlertView secondsSinceBreak =
    div [ Attr.class "alert alert-info alert-dismissible", style [ "font-size" => "1.2em" ] ]
        [ span [ Attr.class "glyphicon glyphicon-exclamation-sign", class [ BufferRight ] ] []
        , text ("How about a walk? You've been mobbing for " ++ toString (secondsSinceBreak // 60) ++ " minutes.")
        ]


tipView : Tip.Tip -> Html Msg
tipView tip =
    div [ Attr.class "jumbotron tip", style [ "margin" => "0px", "padding" => "1.667em" ] ]
        [ div [ Attr.class "row" ]
            [ h2 [ Attr.class "text-success pull-left", style [ "margin" => "0px", "padding-bottom" => "0.667em" ] ]
                [ text tip.title ]
            , a [ Attr.tabindex -1, target "_blank", Attr.class "btn btn-sm btn-primary pull-right", onClick <| Msg.SendIpc Ipc.OpenExternalUrl (Encode.string tip.url) ] [ text "Learn More" ]
            ]
        , div [ Attr.class "row" ] [ Tip.tipView tip ]
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


noTab : Attribute Msg
noTab =
    Attr.tabindex -1


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
            , div [ Attr.class "col-md-8 col-sm-12" ] [ RosterView.rotationView model.dragDrop model.quickRotateState model.settings.rosterData model.activeMobstersStyle (Animation.render model.dieStyle) ]
            ]
        , div []
            [ h3 [] [ text "Getting Started" ]
            , Bootstrap.smallButton "Install Mob Git Commit Script" (Msg.SendIpc Ipc.ShowScriptInstallInstructions Encode.null) Bootstrap.Primary FA.Github
            , Bootstrap.smallButton "Learn to Mob Game" Msg.StartRpgMode Bootstrap.Success FA.Gamepad
            ]
        , button
            [ noTab
            , onClick Msg.StartTimer
            , style [ "margin-top" => "50px" ]
            , Attr.class "btn btn-info btn-lg btn-block"
            , class
                [ BufferTop
                , LargeButtonText
                , TooltipContainer
                ]
            ]
            [ text "Start Mobbing", div [ class [ Tooltip ] ] [ text (startMobbingShortcut model.onMac) ] ]
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
    div [] [ Navbar.view model.screenState, updateAvailableView model.availableUpdateVersion, mainView, feedbackButton ]



-- update function helpers 34


resetBreakData : Model -> Model
resetBreakData model =
    { model | secondsSinceBreak = 0, intervalsSinceBreak = 0 }


resetIfAfterBreak : Model -> Model
resetIfAfterBreak model =
    let
        timeForBreak =
            Break.breakSuggested model.intervalsSinceBreak model.settings.intervalsPerBreak
    in
    if timeForBreak then
        model |> resetBreakData
    else
        model


saveActiveMobsters : ( { model | settings : Settings.Data }, Cmd Msg ) -> ( { model | settings : Settings.Data }, Cmd Msg )
saveActiveMobsters (( model, msg ) as updateResult) =
    updateResult
        |> withIpcMsg Ipc.SaveActiveMobstersFile (Encode.string <| Roster.currentMobsterNames model.settings.rosterData)


updateSettings : (Settings.Data -> Settings.Data) -> { model | settings : Settings.Data } -> ( { model | settings : Settings.Data }, Cmd Msg )
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

        Msg.ShowRotationScreen ->
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

        Msg.StartTimer ->
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
                        |> withIpcMsg Ipc.StartTimer (startTimerFlags False model)
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
                |> withIpcMsg Ipc.StartTimer (startTimerFlags True model)

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
                ! [ shuffleMobstersCmd model.settings.rosterData ]

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

        Msg.SendIpc ipcMsg payload ->
            model ! [ sendIpcCmd ipcMsg payload ]

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
                    if RosterView.preventAddingMobster model.settings.rosterData.mobsters newMobster then
                        model ! []
                    else
                        { model | quickRotateState = QuickRotate.init }
                            ! []
                            |> Update.Extra.andThen update
                                (Msg.UpdateRosterData (MobsterOperation.Add newMobster))

        Msg.QuickRotateMove direction ->
            case direction of
                Msg.Next ->
                    { model
                        | quickRotateState = QuickRotate.next (model.settings.rosterData.inactiveMobsters |> List.map .name) model.quickRotateState
                    }
                        ! []

                Msg.Previous ->
                    { model
                        | quickRotateState = QuickRotate.previous (model.settings.rosterData.inactiveMobsters |> List.map .name) model.quickRotateState
                    }
                        ! []

        Msg.KeyPressed pressed key ->
            case key of
                Keyboard.Extra.Alt ->
                    { model | altPressed = pressed } ! []

                _ ->
                    model ! []

        Msg.Animate animMsg ->
            { model | dieStyle = Animation.update animMsg model.dieStyle, activeMobstersStyle = Animation.update animMsg model.activeMobstersStyle } ! []


type alias Thingy model =
    { model | settings : Settings.Data }



-- performRosterOperation : MobsterOperation -> Thingy model -> ( Thingy model, Cmd Msg )


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
            |> withIpcMsg Ipc.ChangeShortcut (Encode.string shortcutString)


sendIpcCmd : Ipc.Msg -> Encode.Value -> Cmd msg
sendIpcCmd ipcMsg payload =
    Setup.Ports.sendIpc ( toString ipcMsg, payload )


withIpcMsg : Ipc.Msg -> Encode.Value -> ( model, Cmd Msg ) -> ( model, Cmd Msg )
withIpcMsg msgIpc valueEncode ( model, cmd ) =
    model ! [ cmd, sendIpcCmd msgIpc valueEncode ]


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



-- elm boilerplate 73


init : { onMac : Bool, settings : Decode.Value } -> ( Model, Cmd Msg )
init { onMac, settings } =
    let
        decodedSettings =
            Settings.decode settings

        initialSettings =
            case decodedSettings of
                Ok settings ->
                    settings

                Err errorString ->
                    let
                        _ =
                            Debug.log "init failed to decode settings" errorString
                    in
                    Settings.initial
    in
    initialModel initialSettings onMac
        ! []
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
    , activeMobstersStyle : Animation.State
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
    }


main : Program { onMac : Bool, settings : Decode.Value } Model Msg
main =
    Html.programWithFlags
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
