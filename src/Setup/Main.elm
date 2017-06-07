module Setup.Main exposing (main)

import Animation
import Basics.Extra exposing ((=>))
import Bootstrap
import Break
import Dom
import FA
import GlobalShortcut
import Html exposing (..)
import Html.Attributes as Attr exposing (id, placeholder, src, style, target, title, type_, value)
import Html.CssHelpers
import Html.Events exposing (keyCode, on, onCheck, onClick, onInput, onSubmit)
import Html.Events.Extra exposing (onEnter)
import Html5.DragDrop as DragDrop
import Ipc
import Json.Decode as Decode
import Json.Encode as Encode
import Keyboard.Combo
import Keyboard.Extra
import Mobster.Data as Mobster
import Mobster.Operation as MobsterOperation exposing (MobsterOperation)
import Mobster.Presenter as Presenter
import QuickRotate
import Random
import Setup.Forms.ViewHelpers
import Setup.InputField exposing (IntInputField(..))
import Setup.Msg exposing (..)
import Setup.Navbar as Navbar
import Setup.PlotScatter
import Setup.Ports
import Setup.RosterView as RosterView
import Setup.Rpg.View exposing (RpgState(..))
import Setup.Settings as Settings
import Setup.Shortcuts as Shortcuts
import Setup.Stylesheet exposing (CssClasses(..))
import Setup.Validations as Validations
import Setup.View exposing (..)
import Svg
import Task
import Timer.Flags
import Tip
import Update.Extra


{ id, class, classList } =
    Html.CssHelpers.withNamespace "setup"


shuffleMobstersCmd : Mobster.MobsterData -> Cmd Msg
shuffleMobstersCmd mobsterData =
    Random.generate reorderOperation (Mobster.randomizeMobsters mobsterData)


type alias DragDropModel =
    DragDrop.Model DragId DropArea


changeTip : Cmd Msg
changeTip =
    Random.generate NewTip Tip.random


startTimerFlags : Bool -> Model -> Encode.Value
startTimerFlags isBreak model =
    let
        { driver, navigator } =
            Presenter.nextDriverNavigator model.settings.mobsterData

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
                , a [ onClick <| SendIpc Ipc.QuitAndInstall Encode.null, Attr.href "#", Attr.class "alert-link", class [ HandPointer ] ] [ text "Update now" ]
                , text "."
                ]


feedbackButton : Html Msg
feedbackButton =
    div []
        [ a [ onClick <| SendIpc Ipc.ShowFeedbackForm Encode.null, style [ "text-transform" => "uppercase", "transform" => "rotate(-90deg)" ], Attr.tabindex -1, Attr.class "btn btn-sm btn-default pull-right", Attr.id "feedback" ] [ span [ class [ BufferRight ] ] [ text "Feedback" ], span [ Attr.class "fa fa-comment-o" ] [] ] ]


continueButtonChildren : Model -> List (Html Msg)
continueButtonChildren model =
    case model.experiment of
        Just experimentText ->
            [ div [ Attr.class "col-md-4" ] [ text "Continue" ]
            , div
                [ Attr.class "col-md-8"
                , style
                    [ "font-style" => "italic"
                    , "text-align" => "left"
                    ]
                ]
                [ text experimentText ]
            ]

        Nothing ->
            [ div [] [ text "Continue" ] ]


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



-- continuous retros 29


experimentView : String -> Maybe String -> Html Msg
experimentView newExperiment maybeExperiment =
    case maybeExperiment of
        Just experiment ->
            div [] [ text experiment, button [ noTab, onClick ChangeExperiment, Attr.class "btn btn-sm btn-primary" ] [ text "Edit experiment" ] ]

        Nothing ->
            div [ Attr.class "input-group" ]
                [ input [ id "add-mobster", placeholder "Try a daily experiment", type_ "text", Attr.class "form-control", value newExperiment, onInput (ChangeInput (StringField Experiment)), onEnter SetExperiment, style [ "font-size" => "1.8rem" ] ] []
                , span [ Attr.class "input-group-btn", type_ "button" ] [ button [ noTab, Attr.class "btn btn-primary", onClick SetExperiment ] [ text "Set" ] ]
                ]


ratingsToPlotData : List Int -> List ( Float, Float )
ratingsToPlotData ratings =
    List.indexedMap (\index value -> ( toFloat index, toFloat value )) ratings


ratingsView : Model -> Svg.Svg Msg
ratingsView model =
    case model.experiment of
        Just _ ->
            if List.length model.ratings > 0 then
                Setup.PlotScatter.view (ratingsToPlotData model.ratings)
            else
                div [] []

        Nothing ->
            div [] []



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
    div [ onClick ResetBreakData ] intervalBadges



-- continue view 92


continueButtonId : String
continueButtonId =
    "continue-button"


continueButtons : Model -> Html Msg
continueButtons model =
    div [ Attr.class "row", style [ "padding-bottom" => "1.333em" ] ]
        [ button
            [ noTab
            , onClick StartTimer
            , Attr.class "btn btn-info btn-lg btn-block"
            , class [ LargeButtonText, BufferTop, TooltipContainer ]
            , Attr.id continueButtonId
            ]
            (continueButtonChildren model ++ [ div [ class [ Tooltip ] ] [ text (startMobbingShortcut model.onMac) ] ])
        ]


continueView : Bool -> Model -> Html Msg
continueView showRotation model =
    let
        mainView =
            if showRotation then
                div []
                    [ RosterView.rotationView model model.settings.mobsterData
                    , button [ style [ "margin-bottom" => "12px" ], Attr.class "btn btn-small btn-default pull-right", onClick ShowRotationScreen ]
                        [ span [ class [ BufferRight ] ] [ text "Back to tip view" ], span [ Attr.class "fa fa-arrow-circle-o-left" ] [] ]
                    ]
            else
                div [ onClick ShowRotationScreen ]
                    [ table [ Attr.class "table table-hover" ] [ tbody [] [ RosterView.newMobsterRowView model.quickRotateState False ] ]
                    , tipView model.tip
                    ]
    in
    if Break.breakSuggested model.intervalsSinceBreak model.settings.intervalsPerBreak then
        breakView model
    else
        div [ Attr.class "container-fluid" ]
            [ viewIntervalsBeforeBreak model
            , ratingsView model
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
                , onClick SkipBreak
                , Attr.class "btn btn-default btn-lg btn-block"
                , class [ LargeButtonText, BufferTop, BufferRight, TooltipContainer, ButtonMuted ]
                ]
                [ span [] [ text "Skip Break" ] ]
            ]
        , div [ Attr.class "col-md-9" ]
            [ button
                [ noTab
                , onClick StartBreak
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
            , a [ Attr.tabindex -1, target "_blank", Attr.class "btn btn-sm btn-primary pull-right", onClick <| SendIpc Ipc.OpenExternalUrl (Encode.string tip.url) ] [ text "Learn More" ]
            ]
        , div [ Attr.class "row" ] [ Tip.tipView tip ]
        ]


nextDriverNavigatorView : Model -> Html Msg
nextDriverNavigatorView model =
    let
        driverNavigator =
            Presenter.nextDriverNavigator model.settings.mobsterData

        fastForwardButton =
            div [ Attr.class "col-md-1 col-sm-1 text-default" ]
                [ span [ Attr.class "btn btn-sm btn-default btn-block", style [ "font-size" => "23px", "padding-right" => "4px" ], class [ ShowOnParentHover ], onClick <| UpdateMobsterData MobsterOperation.NextTurn ]
                    [ span [ Attr.class "fa fa-fast-forward text-warning" ] []
                    ]
                ]

        rewindButton =
            div [ Attr.class "col-md-1 col-sm-1 text-default" ]
                [ span [ Attr.class "btn btn-sm btn-default btn-block", style [ "font-size" => "23px", "padding-right" => "4px" ], class [ ShowOnParentHover ], onClick <| UpdateMobsterData MobsterOperation.RewindTurn ]
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
                , onClick <| UpdateMobsterData (MobsterOperation.Bench mobster.index)
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
            , div [ Attr.class "col-md-8 col-sm-12" ] [ RosterView.rotationView model model.settings.mobsterData ]
            ]
        , div []
            [ h3 [] [ text "Getting Started" ]
            , Bootstrap.smallButton "Install Mob Git Commit Script" (SendIpc Ipc.ShowScriptInstallInstructions Encode.null) Bootstrap.Primary FA.Github
            , Bootstrap.smallButton "Learn to Mob Game" StartRpgMode Bootstrap.Success FA.Gamepad
            ]
        , button
            [ noTab
            , onClick StartTimer
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
            , onInput (ChangeInput (StringField ShowHideShortcut))
            , class [ BufferRight ]
            , value currentShortcut
            , style [ "font-size" => "4.0rem", "width" => "40px" ]
            , Attr.maxlength 1
            ]
            []
        ]


addMobsterInputView : String -> Mobster.MobsterData -> Html Msg
addMobsterInputView newMobster mobsterData =
    let
        hasError =
            Mobster.containsName newMobster mobsterData
    in
    div [ Attr.class "row" ]
        [ div [ Attr.class "input-group" ]
            [ input [ id "add-mobster", Attr.placeholder "Jane Doe", type_ "text", classList [ HasError => hasError ], Attr.class "form-control", value newMobster, onInput <| ChangeInput (StringField NewMobster), onEnter AddMobster, style [ "font-size" => "2.0rem" ] ] []
            , span [ Attr.class "input-group-btn", type_ "button" ] [ button [ noTab, Attr.class "btn btn-primary", onClick ClickAddMobster ] [ text "Add Mobster" ] ]
            ]
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
                    Setup.Rpg.View.rpgView rpgState model.settings.mobsterData
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


saveActiveMobsters : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
saveActiveMobsters (( model, msg ) as updateResult) =
    updateResult
        |> Update.Extra.andThen update (SendIpc Ipc.SaveActiveMobstersFile (Encode.string <| Mobster.currentMobsterNames model.settings.mobsterData))


updateSettings : (Settings.Data -> Settings.Data) -> Model -> ( Model, Cmd Msg )
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
        SkipHotkey ->
            case model.screenState of
                Continue showRotation ->
                    update (UpdateMobsterData MobsterOperation.NextTurn) model

                _ ->
                    model ! []

        StartRpgMode ->
            { model | screenState = Rpg NextUp } ! []

        ShowRotationScreen ->
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

        StartTimer ->
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
                        |> Update.Extra.andThen update (SendIpc Ipc.StartTimer (startTimerFlags False model))
            in
            case model.screenState of
                Rpg rpgState ->
                    startTimerUpdate

                _ ->
                    startTimerUpdate |> Update.Extra.andThen update (UpdateMobsterData MobsterOperation.NextTurn)

        SkipBreak ->
            let
                updatedModel =
                    { model | screenState = Continue False }
                        |> resetBreakData
            in
            updatedModel ! []

        StartBreak ->
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
                |> Update.Extra.andThen update (SendIpc Ipc.StartTimer (startTimerFlags True model))

        SelectInputField fieldId ->
            model ! [ Setup.Ports.selectDuration fieldId ]

        OpenConfigure ->
            { model | screenState = Configure } ! []

        AddMobster ->
            if model.newMobster == "" || Mobster.containsName model.newMobster model.settings.mobsterData then
                model ! []
            else
                update (UpdateMobsterData (MobsterOperation.Add model.newMobster)) { model | newMobster = "" }

        ClickAddMobster ->
            if model.newMobster == "" then
                model ! [ focusAddMobsterInput ]
            else
                { model | newMobster = "" }
                    ! [ focusAddMobsterInput ]
                    |> Update.Extra.andThen update (UpdateMobsterData (MobsterOperation.Add model.newMobster))

        DomResult _ ->
            model ! []

        UpdateMobsterData operation ->
            model
                |> updateSettings
                    (\settings -> { settings | mobsterData = MobsterOperation.updateMoblist operation model.settings.mobsterData })
                |> saveActiveMobsters
                |> focusQuickRotateInputIfVisible
                |> updateQuickRotateStateIfActive

        ComboMsg comboMsg ->
            let
                ( combos, cmd ) =
                    Keyboard.Combo.update comboMsg model.combos
            in
            ( { model | combos = combos }, cmd )

        NewTip tipIndex ->
            { model | tip = Tip.get tipIndex } ! []

        SetExperiment ->
            if model.newExperiment == "" then
                model ! []
            else
                { model | experiment = Just model.newExperiment } ! []

        ChangeExperiment ->
            { model | experiment = Nothing } ! []

        EnterRating rating ->
            update StartTimer { model | ratings = model.ratings ++ [ rating ] }

        ShuffleMobsters ->
            { model
                | dieStyle =
                    Animation.interrupt
                        [ Animation.set
                            [ Animation.rotate (Animation.turn 1) ]
                        , Animation.to
                            [ Animation.rotate (Animation.turn 0) ]
                        ]
                        model.dieStyle
            }
                ! [ shuffleMobstersCmd model.settings.mobsterData ]

        TimeElapsed elapsedSeconds ->
            { model | secondsSinceBreak = model.secondsSinceBreak + elapsedSeconds, intervalsSinceBreak = model.intervalsSinceBreak + 1 } ! []

        BreakDone elapsedSeconds ->
            model ! []

        ResetBreakData ->
            (model |> resetBreakData) ! []

        UpdateAvailable availableUpdateVersion ->
            { model | availableUpdateVersion = Just availableUpdateVersion } ! []

        RotateOutHotkey index ->
            if rosterViewIsShowing model.screenState then
                update (UpdateMobsterData (MobsterOperation.Bench index)) model
            else
                model ! []

        RotateInHotkey index ->
            if rosterViewIsShowing model.screenState then
                update (UpdateMobsterData (MobsterOperation.RotateIn index)) model
            else
                model ! []

        DragDropMsg dragDropMsg ->
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
                        ( ActiveMobster id, DropActiveMobster actualDropid ) ->
                            update (UpdateMobsterData (MobsterOperation.Move id actualDropid)) updatedModel

                        ( ActiveMobster id, DropBench ) ->
                            update (UpdateMobsterData (MobsterOperation.Bench id)) updatedModel

                        ( InactiveMobster inactiveMobsterId, DropActiveMobster activeMobsterId ) ->
                            update (UpdateMobsterData (MobsterOperation.RotateIn inactiveMobsterId)) updatedModel

                        _ ->
                            model ! []

        SendIpc ipcMessage payload ->
            model ! [ Setup.Ports.sendIpc ( toString ipcMessage, payload ) ]

        CheckRpgBox msg checkedValue ->
            update msg model

        ViewRpgNextUp ->
            { model | screenState = Rpg NextUp }
                ! []
                |> Update.Extra.andThen update
                    (UpdateMobsterData MobsterOperation.NextTurn)

        ChangeInput inputField newInputValue ->
            case inputField of
                StringField stringField ->
                    case stringField of
                        ShowHideShortcut ->
                            changeGlobalShortcutIfValid model newInputValue

                        Experiment ->
                            { model | newExperiment = newInputValue } ! []

                        NewMobster ->
                            { model | newMobster = newInputValue } ! []

                        QuickRotateQuery ->
                            if model.altPressed then
                                model ! []
                            else
                                { model | quickRotateState = QuickRotate.update newInputValue (model.settings.mobsterData.inactiveMobsters |> List.map .name) model.quickRotateState } ! []

                IntField intField ->
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

        NoOp ->
            model
                ! []

        QuickRotateAdd ->
            case model.quickRotateState.selection of
                QuickRotate.Index benchIndex ->
                    { model | quickRotateState = QuickRotate.init }
                        ! []
                        |> Update.Extra.andThen update
                            (UpdateMobsterData (MobsterOperation.RotateIn benchIndex))

                QuickRotate.All ->
                    model ! []

                QuickRotate.New newMobster ->
                    if RosterView.preventAddingMobster model.settings.mobsterData.mobsters newMobster then
                        model ! []
                    else
                        { model | quickRotateState = QuickRotate.init }
                            ! []
                            |> Update.Extra.andThen update
                                (UpdateMobsterData (MobsterOperation.Add newMobster))

        QuickRotateMove direction ->
            case direction of
                Next ->
                    { model
                        | quickRotateState = QuickRotate.next (model.settings.mobsterData.inactiveMobsters |> List.map .name) model.quickRotateState
                    }
                        ! []

                Previous ->
                    { model
                        | quickRotateState = QuickRotate.previous (model.settings.mobsterData.inactiveMobsters |> List.map .name) model.quickRotateState
                    }
                        ! []

        Setup.Msg.KeyPressed pressed key ->
            case key of
                Keyboard.Extra.Alt ->
                    { model | altPressed = pressed } ! []

                _ ->
                    model ! []

        Animate animMsg ->
            { model | dieStyle = Animation.update animMsg model.dieStyle } ! []


changeGlobalShortcutIfValid : Model -> String -> ( Model, Cmd Msg )
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
            |> Update.Extra.andThen update
                (SendIpc Ipc.ChangeShortcut (Encode.string shortcutString))


rosterViewIsShowing : ScreenState -> Bool
rosterViewIsShowing screenState =
    screenState == Continue True || screenState == Configure


keyboardComboInit : Keyboard.Combo.Model Msg
keyboardComboInit =
    Keyboard.Combo.init
        { toMsg = ComboMsg
        , combos = Shortcuts.keyboardCombos
        }


focusQuickRotateInput : Cmd Msg
focusQuickRotateInput =
    quickRotateQueryId
        |> Dom.focus
        |> Task.attempt DomResult


focusQuickRotateInputIfVisible : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
focusQuickRotateInputIfVisible (( model, cmd ) as updateResult) =
    if model.screenState == Continue True then
        model ! [ cmd, focusQuickRotateInput ]
    else
        updateResult


updateQuickRotateStateIfActive : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateQuickRotateStateIfActive (( model, cmd ) as updateResult) =
    if model.screenState == Continue True then
        ( { model | quickRotateState = QuickRotate.update model.quickRotateState.query (model.settings.mobsterData.inactiveMobsters |> List.map .name) model.quickRotateState }, cmd )
    else
        updateResult


quickRotateQueryId : String
quickRotateQueryId =
    "quick-rotate-query"


reorderOperation : List Mobster.Mobster -> Msg
reorderOperation shuffledMobsters =
    UpdateMobsterData (MobsterOperation.Reorder shuffledMobsters)


focusAddMobsterInput : Cmd Msg
focusAddMobsterInput =
    "add-mobster"
        |> Dom.focus
        |> Task.attempt DomResult


blurContinueButton : Cmd Msg
blurContinueButton =
    continueButtonId
        |> Dom.blur
        |> Task.attempt DomResult



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
            (ChangeInput (StringField ShowHideShortcut) initialSettings.showHideShortcut)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Keyboard.Combo.subscriptions model.combos
        , Setup.Ports.timeElapsed TimeElapsed
        , Setup.Ports.breakDone BreakDone
        , Setup.Ports.updateDownloaded UpdateAvailable
        , Keyboard.Extra.downs (KeyPressed True)
        , Keyboard.Extra.ups (KeyPressed False)
        , Animation.subscription Animate [ model.dieStyle ]
        ]


type alias Model =
    { settings : Settings.Data
    , screenState : ScreenState
    , newMobster : String
    , combos : Keyboard.Combo.Model Msg
    , tip : Tip.Tip
    , experiment : Maybe String
    , newExperiment : String
    , ratings : List Int
    , secondsSinceBreak : Int
    , intervalsSinceBreak : Int
    , availableUpdateVersion : Maybe String
    , dragDrop : DragDropModel
    , onMac : Bool
    , quickRotateState : QuickRotate.State
    , altPressed : Bool
    , dieStyle : Animation.State
    }


initialModel : Settings.Data -> Bool -> Model
initialModel settings onMac =
    { settings = settings
    , screenState = Configure
    , newMobster = ""
    , combos = keyboardComboInit
    , tip = Tip.emptyTip
    , experiment = Nothing
    , newExperiment = ""
    , ratings = []
    , secondsSinceBreak = 0
    , intervalsSinceBreak = 0
    , availableUpdateVersion = Nothing
    , dragDrop = DragDrop.init
    , onMac = onMac
    , quickRotateState = QuickRotate.init
    , altPressed = False
    , dieStyle =
        Animation.style
            [ Animation.rotate (Animation.turn 0.0)
            ]
    }


main : Program { onMac : Bool, settings : Decode.Value } Model Msg
main =
    Html.programWithFlags
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
