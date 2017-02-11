port module Setup.Main exposing (..)

import Html exposing (..)
import Html.Attributes as Attr exposing (value, type_, id, style, src, title, href, target, placeholder)
import Html.Events exposing (on, keyCode, onClick, onInput, onSubmit)
import Json.Decode as Json
import Task
import Dom
import Mobster exposing (MobsterOperation)
import Json.Decode as Decode
import Keyboard.Combo
import Random
import Tip
import Setup.PlotScatter
import Svg
import Update.Extra
import Html.CssHelpers
import Setup.Stylesheet exposing (CssClasses(..))
import Break


{ id, class, classList } =
    Html.CssHelpers.withNamespace "setup"
shuffleMobstersCmd : Mobster.MobsterData -> Cmd Msg
shuffleMobstersCmd mobsterData =
    Random.generate reorderOperation (Mobster.randomizeMobsters mobsterData)


type Msg
    = StartTimer
    | UpdateMobsterData MobsterOperation
    | UpdateMobsterInput String
    | AddMobster
    | ClickAddMobster
    | DomFocusResult (Result Dom.Error ())
    | ChangeTimerDuration String
    | ChangeBreakInterval String
    | SelectDurationInput
    | OpenConfigure
    | NewTip Int
    | SetExperiment
    | ChangeExperiment
    | UpdateExperimentInput String
    | EnterRating Int
    | Quit
    | QuitAndInstall
    | ComboMsg Keyboard.Combo.Msg
    | ShuffleMobsters
    | TimeElapsed Int
    | UpdateAvailable String
    | CopyActiveMobsters ()
    | ResetBreakData


keyboardCombos : List (Keyboard.Combo.KeyCombo Msg)
keyboardCombos =
    [ Keyboard.Combo.combo2 ( Keyboard.Combo.control, Keyboard.Combo.enter ) StartTimer
    , Keyboard.Combo.combo2 ( Keyboard.Combo.command, Keyboard.Combo.enter ) StartTimer
    , Keyboard.Combo.combo2 ( Keyboard.Combo.shift, Keyboard.Combo.one ) (EnterRating 1)
    , Keyboard.Combo.combo2 ( Keyboard.Combo.shift, Keyboard.Combo.two ) (EnterRating 2)
    , Keyboard.Combo.combo2 ( Keyboard.Combo.shift, Keyboard.Combo.three ) (EnterRating 3)
    ]


type ScreenState
    = Configure
    | Continue


type alias Model =
    { timerDuration : Int
    , screenState : ScreenState
    , mobsterData : Mobster.MobsterData
    , newMobster : String
    , combos : Keyboard.Combo.Model Msg
    , tip : Tip.Tip
    , experiment : Maybe String
    , newExperiment : String
    , ratings : List Int
    , secondsSinceBreak : Int
    , intervalsSinceBreak : Int
    , intervalsPerBreak : Int
    , availableUpdateVersion : Maybe String
    }


changeTip : Cmd Msg
changeTip =
    Random.generate NewTip Tip.random


initialModel : Model
initialModel =
    { timerDuration = 5
    , screenState = Configure
    , mobsterData = Mobster.empty
    , newMobster = ""
    , combos = Keyboard.Combo.init ComboMsg keyboardCombos
    , tip = Tip.emptyTip
    , experiment = Nothing
    , newExperiment = ""
    , ratings = []
    , secondsSinceBreak = 0
    , intervalsSinceBreak = 0
    , intervalsPerBreak = 6
    , availableUpdateVersion = Nothing
    }


type alias TimerConfiguration =
    { minutes : Int, driver : String, navigator : String }


flags : Model -> TimerConfiguration
flags model =
    let
        driverNavigator =
            Mobster.nextDriverNavigator model.mobsterData
    in
        { minutes = model.timerDuration
        , driver = driverNavigator.driver.name
        , navigator = driverNavigator.navigator.name
        }


port startTimer : TimerConfiguration -> Cmd msg


port saveSetup : Mobster.MobsterData -> Cmd msg


port quit : () -> Cmd msg


port quitAndInstall : () -> Cmd msg


port selectDuration : String -> Cmd msg


port copyActiveMobsters : String -> Cmd msg


port timeElapsed : (Int -> msg) -> Sub msg


port updateDownloaded : (String -> msg) -> Sub msg


port onCopyMobstersShortcut : (() -> msg) -> Sub msg


timerDurationInputView : Int -> Html Msg
timerDurationInputView duration =
    div [ Attr.class "text-primary h1" ]
        [ input
            [ id "timer-duration"
            , onClick SelectDurationInput
            , onInput ChangeTimerDuration
            , type_ "number"
            , Attr.min "1"
            , Attr.max "15"
            , value (toString duration)
            , class [ BufferRight ]
            , style [ ( "font-size", "60px" ) ]
            ]
            []
        , text "Minutes"
        ]


breakIntervalInputView : Int -> Int -> Html Msg
breakIntervalInputView intervalsPerBreak timerDuration =
    let
        theString =
            if intervalsPerBreak > 0 then
                "intervals per break (" ++ (toString (intervalsPerBreak * timerDuration)) ++ " minutes" ++ ")"
            else
                "Breaks off"
    in
        div [ Attr.class "text-primary h3" ]
            [ input
                [ id "break-interval"
                , onInput ChangeBreakInterval
                , type_ "number"
                , Attr.min "0"
                , Attr.max "30"
                , value (toString intervalsPerBreak)
                , class [ BufferRight ]
                , style [ ( "font-size", "60px" ) ]
                ]
                []
            , text theString
            ]


quitButton : Html Msg
quitButton =
    button [ onClick Quit, Attr.class "btn btn-primary btn-md btn-block" ] [ text "Quit" ]


titleTextView : Html msg
titleTextView =
    h1 [ Attr.class "text-info text-center", id "mobster-title", style [ ( "font-size", "62px" ) ] ] [ text "Mobster" ]


invisibleTrigger : Html msg
invisibleTrigger =
    img [ src "./assets/invisible.png", Attr.class "invisible-trigger pull-left", style [ ( "max-width", "35px" ) ] ] []


configureView : Model -> Html Msg
configureView model =
    div [ Attr.class "container-fluid" ]
        [ div [ Attr.class "row" ]
            [ invisibleTrigger
            , titleTextView
            ]
        , button [ onClick StartTimer, Attr.class "btn btn-info btn-lg btn-block", class [ BufferTop ], title "Ctrl+Enter or ⌘+Enter", style [ ( "font-size", "30px" ), ( "padding", "20px" ) ] ] [ text "Start Mobbing" ]
        , div [ Attr.class "row" ]
            [ div [ Attr.class "col-md-4" ] [ timerDurationInputView model.timerDuration, breakIntervalInputView model.intervalsPerBreak model.timerDuration ]
            , div [ Attr.class "col-md-4" ] [ mobstersView model.newMobster (Mobster.mobsters model.mobsterData) ]
            , div [ Attr.class "col-md-4" ] [ inactiveMobstersView model.mobsterData.inactiveMobsters ]
            ]
        , div [ Attr.class "h1" ] [ experimentView model.newExperiment model.experiment ]
        , div [ Attr.class "row", class [ BufferTop ] ] [ quitButton ]
        ]


experimentView : String -> Maybe String -> Html Msg
experimentView newExperiment maybeExperiment =
    case maybeExperiment of
        Just experiment ->
            div [] [ text experiment, button [ onClick ChangeExperiment, Attr.class "btn btn-sm btn-primary" ] [ text "Edit experiment" ] ]

        Nothing ->
            div [ Attr.class "input-group" ]
                [ input [ id "add-mobster", placeholder "Try a daily experiment", type_ "text", Attr.class "form-control", value newExperiment, onInput UpdateExperimentInput, onEnter SetExperiment, style [ ( "font-size", "30px" ) ] ] []
                , span [ Attr.class "input-group-btn", type_ "button" ] [ button [ Attr.class "btn btn-primary", onClick SetExperiment ] [ text "Set" ] ]
                ]


continueButtonChildren : Model -> List (Html Msg)
continueButtonChildren model =
    case model.experiment of
        Just experimentText ->
            [ div [ Attr.class "col-md-4" ] [ text "Continue" ]
            , div
                [ Attr.class "col-md-8"
                , style
                    [ ( "font-size", "22px" )
                    , ( "font-style", "italic" )
                    , ( "text-align", "left" )
                    ]
                ]
                [ text experimentText ]
            ]

        Nothing ->
            [ div [] [ text "Continue" ] ]


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


breakView : Int -> Int -> Int -> Html msg
breakView secondsSinceBreak intervalsSinceBreak intervalsPerBreak =
    if intervalsPerBreak > 0 && Break.breakSuggested intervalsSinceBreak intervalsPerBreak then
        div [ Attr.class "alert alert-warning alert-dismissible", style [ ( "font-size", "20px" ) ] ]
            [ span [ Attr.class "glyphicon glyphicon-exclamation-sign", class [ BufferRight ] ] []
            , text ("How about a walk? (You've been mobbing for " ++ (toString (secondsSinceBreak // 60)) ++ " minutes.)")
            ]
    else
        div [] []


viewIntervalsBeforeBreak : Model -> Html Msg
viewIntervalsBeforeBreak model =
    let
        remainingIntervals =
            Break.timersBeforeNext model.intervalsSinceBreak model.intervalsPerBreak

        intervalBadges =
            List.range 1 model.intervalsPerBreak
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


continueView : Model -> Html Msg
continueView model =
    div [ Attr.class "container-fluid" ]
        [ div [ Attr.class "row" ]
            [ invisibleTrigger
            , titleTextView
            ]
        , ratingsView model
        , div [] [ viewIntervalsBeforeBreak model ]
        , breakView model.secondsSinceBreak model.intervalsSinceBreak model.intervalsPerBreak
        , div [ Attr.class "row", style [ ( "padding-bottom", "20px" ) ] ]
            [ button
                [ onClick StartTimer
                , Attr.class "btn btn-info btn-lg btn-block"
                , class [ BufferTop ]
                , title "Ctrl+Enter or ⌘+Enter"
                , style [ ( "font-size", "30px" ), ( "padding", "20px" ) ]
                ]
                (continueButtonChildren model)
            ]
        , nextDriverNavigatorView model
        , tipView model.tip
        , div [ Attr.class "row", class [ BufferTop ], style [ ( "padding-bottom", "20px" ) ] ] [ button [ onClick OpenConfigure, Attr.class "btn btn-primary btn-md btn-block" ] [ text "Configure" ] ]
        , div [ Attr.class "row", class [ BufferTop ] ] [ quitButton ]
        ]


tipView : Tip.Tip -> Html Msg
tipView tip =
    div [ Attr.class "jumbotron tip", style [ ( "margin", "0px" ), ( "padding", "25px" ) ] ]
        [ div [ Attr.class "row" ]
            [ h2 [ Attr.class "text-success pull-left", style [ ( "margin", "0px" ), ( "padding-bottom", "10px" ) ] ]
                [ text tip.title ]
            , a [ target "_blank", Attr.class "btn btn-sm btn-primary pull-right", href tip.url ] [ text "Learn More" ]
            ]
        , div [ Attr.class "row", style [ ( "font-size", "20px" ) ] ] [ Tip.tipView tip ]
        ]


nextDriverNavigatorView : Model -> Html Msg
nextDriverNavigatorView model =
    let
        driverNavigator =
            Mobster.nextDriverNavigator model.mobsterData
    in
        div [ Attr.class "row h1" ]
            [ div [ Attr.class "text-muted col-md-3" ] [ text "Next:" ]
            , dnView driverNavigator.driver Mobster.Driver
            , dnView driverNavigator.navigator Mobster.Navigator
            , button [ Attr.class "btn btn-small btn-default", onClick (UpdateMobsterData Mobster.SkipTurn) ] [ text "Skip Turn" ]
            ]


dnView : Mobster.Mobster -> Mobster.Role -> Html Msg
dnView mobster role =
    let
        icon =
            case role of
                Mobster.Driver ->
                    "./assets/driver-icon.png"

                Mobster.Navigator ->
                    "./assets/navigator-icon.png"
    in
        div [ Attr.class "col-md-4 text-default" ]
            [ iconView icon 40
            , span [ class [ BufferRight ] ] [ text mobster.name ]
            , button [ onClick (UpdateMobsterData (Mobster.Bench mobster.index)), Attr.class "btn btn-small btn-default" ] [ text "Not here" ]
            ]


iconView : String -> Int -> Html msg
iconView iconUrl maxWidth =
    img [ style [ ( "max-width", (toString maxWidth) ++ "px" ), ( "margin-right", "8px" ) ], src iconUrl ] []


nextView : String -> String -> Html msg
nextView thing name =
    span []
        [ span [ Attr.class "text-muted" ] [ text ("Next " ++ thing ++ ": ") ]
        , span [ Attr.class "text-info" ] [ text name ]
        ]


addMobsterInputView : String -> Html Msg
addMobsterInputView newMobster =
    div [ Attr.class "row", class [ BufferTop ] ]
        [ div [ Attr.class "input-group" ]
            [ input [ id "add-mobster", Attr.placeholder "Jane Doe", type_ "text", Attr.class "form-control", value newMobster, onInput UpdateMobsterInput, onEnter AddMobster, style [ ( "font-size", "30px" ) ] ] []
            , span [ Attr.class "input-group-btn", type_ "button" ] [ button [ Attr.class "btn btn-primary", onClick ClickAddMobster ] [ text "Add Mobster" ] ]
            ]
        ]


mobstersView : String -> List Mobster.MobsterWithRole -> Html Msg
mobstersView newMobster mobsters =
    div [ style [ ( "padding-bottom", "35px" ) ] ]
        [ addMobsterInputView newMobster
        , img [ onClick ShuffleMobsters, Attr.class "shuffle", class [ BufferTop ], src "./assets/dice.png", style [ ( "max-width", "25px" ) ] ] []
        , table [ Attr.class "table h3" ] (List.map mobsterView mobsters)
        ]


inactiveMobstersView : List String -> Html Msg
inactiveMobstersView inactiveMobsters =
    div []
        [ h2 [ Attr.class "text-center text-primary" ] [ text "Bench" ]
        , table [ Attr.class "table h3" ] (List.indexedMap inactiveMobsterView inactiveMobsters)
        ]


inactiveMobsterView : Int -> String -> Html Msg
inactiveMobsterView mobsterIndex inactiveMobster =
    tr []
        [ td [] []
        , td [ style [ ( "width", "200px" ), ( "min-width", "200px" ), ( "text-align", "right" ), ( "padding-right", "10px" ) ] ]
            [ span [ Attr.class "inactive-mobster", onClick (UpdateMobsterData (Mobster.RotateIn mobsterIndex)) ] [ text inactiveMobster ]
            , div [ Attr.class "btn-group btn-group-xs", style [ ( "margin-left", "10px" ) ] ]
                [ button [ Attr.class "btn btn-small btn-danger", onClick (UpdateMobsterData (Mobster.Remove mobsterIndex)) ] [ text "x" ]
                ]
            ]
        ]


mobsterView : Mobster.MobsterWithRole -> Html Msg
mobsterView mobster =
    tr []
        [ td [] []
        , td [ style [ ( "width", "200px" ), ( "min-width", "200px" ), ( "text-align", "right" ), ( "padding-right", "10px" ) ] ]
            [ span [ Attr.classList [ ( "text-primary", mobster.role == Just Mobster.Driver ) ], Attr.class "active-mobster", onClick (UpdateMobsterData (Mobster.SetNextDriver mobster.index)) ]
                [ text mobster.name
                , roleView mobster.role
                ]
            ]
        , td [] [ reorderButtonView mobster ]
        ]


roleView : Maybe Mobster.Role -> Html Msg
roleView role =
    case role of
        Just (Mobster.Driver) ->
            span [ Attr.class "role-icon driver-icon" ] []

        Just (Mobster.Navigator) ->
            span [ Attr.class "role-icon navigator-icon" ] []

        Nothing ->
            span [ Attr.class "role-icon no-role-icon" ] []


reorderButtonView : Mobster.MobsterWithRole -> Html Msg
reorderButtonView mobster =
    let
        mobsterIndex =
            mobster.index
    in
        div []
            [ div [ Attr.class "btn-group btn-group-xs" ]
                [ button [ Attr.class "btn btn-small btn-default", onClick (UpdateMobsterData (Mobster.MoveUp mobsterIndex)) ] [ text "↑" ]
                , button [ Attr.class "btn btn-small btn-default", onClick (UpdateMobsterData (Mobster.MoveDown mobsterIndex)) ] [ text "↓" ]
                , button [ Attr.class "btn btn-small btn-default", onClick (UpdateMobsterData (Mobster.Bench mobsterIndex)) ] [ text "x" ]
                ]
            ]


updateAvailableView : Maybe String -> Html Msg
updateAvailableView availableUpdateVersion =
    case availableUpdateVersion of
        Nothing ->
            div [] []

        Just version ->
            div [ Attr.class "alert alert-success" ]
                [ span [ Attr.class "glyphicon glyphicon-flag", class [ BufferRight ] ] []
                , text ("A new version is downloaded and ready to install. ")
                , a [ onClick QuitAndInstall, Attr.href "#", Attr.class "alert-link" ] [ text "Update now" ]
                , text "."
                ]


view : Model -> Html Msg
view model =
    let
        mainView =
            case model.screenState of
                Configure ->
                    configureView model

                Continue ->
                    continueView model
    in
        div [] [ updateAvailableView model.availableUpdateVersion, mainView ]


resetBreakData : Model -> Model
resetBreakData model =
    { model | secondsSinceBreak = 0, intervalsSinceBreak = 0 }


resetIfAfterBreak : Model -> Model
resetIfAfterBreak model =
    let
        timeForBreak =
            Break.breakSuggested model.intervalsSinceBreak model.intervalsPerBreak
    in
        if timeForBreak then
            model |> resetBreakData
        else
            model


rotateMobsters : Model -> Model
rotateMobsters model =
    { model | mobsterData = (Mobster.rotate model.mobsterData) }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        StartTimer ->
            let
                updatedModel =
                    { model | screenState = Continue }
                        |> rotateMobsters
                        |> resetIfAfterBreak
            in
                updatedModel ! [ (startTimer (flags model)), changeTip ]

        ChangeTimerDuration newDurationAsString ->
            { model | timerDuration = (validateTimerDuration newDurationAsString model.timerDuration) } ! []

        ChangeBreakInterval newIntervalAsString ->
            { model | intervalsPerBreak = (validateBreakInterval newIntervalAsString model.intervalsPerBreak) } ! []

        SelectDurationInput ->
            model ! [ selectDuration "timer-duration" ]

        OpenConfigure ->
            { model | screenState = Configure } ! []

        AddMobster ->
            if model.newMobster == "" then
                model ! []
            else
                update (UpdateMobsterData (Mobster.Add model.newMobster)) { model | newMobster = "" }

        ClickAddMobster ->
            if model.newMobster == "" then
                model ! [ focusAddMobsterInput ]
            else
                { model | newMobster = "" }
                    ! [ focusAddMobsterInput ]
                    |> Update.Extra.andThen update (UpdateMobsterData (Mobster.Add model.newMobster))

        DomFocusResult _ ->
            model ! []

        UpdateMobsterData operation ->
            let
                updatedMobsterData =
                    Mobster.updateMoblist operation model.mobsterData
            in
                { model | mobsterData = updatedMobsterData } ! [ saveSetup updatedMobsterData ]

        UpdateMobsterInput text ->
            { model | newMobster = text } ! []

        Quit ->
            model ! [ quit () ]

        ComboMsg msg ->
            let
                updatedCombos =
                    Keyboard.Combo.update msg model.combos
            in
                { model | combos = updatedCombos } ! []

        NewTip tipIndex ->
            { model | tip = (Tip.get tipIndex) } ! []

        SetExperiment ->
            if model.newExperiment == "" then
                model ! []
            else
                { model | experiment = Just model.newExperiment } ! []

        UpdateExperimentInput newExperiment ->
            { model | newExperiment = newExperiment } ! []

        ChangeExperiment ->
            { model | experiment = Nothing } ! []

        EnterRating rating ->
            update StartTimer { model | ratings = model.ratings ++ [ rating ] }

        ShuffleMobsters ->
            model ! [ shuffleMobstersCmd model.mobsterData ]

        TimeElapsed elapsedSeconds ->
            { model | secondsSinceBreak = (model.secondsSinceBreak + elapsedSeconds), intervalsSinceBreak = model.intervalsSinceBreak + 1 } ! []

        CopyActiveMobsters _ ->
            model ! [ (copyActiveMobsters (String.join ", " model.mobsterData.mobsters)) ]

        ResetBreakData ->
            (model |> resetBreakData) ! []

        UpdateAvailable availableUpdateVersion ->
            { model | availableUpdateVersion = Just availableUpdateVersion } ! []

        QuitAndInstall ->
            model ! [ quitAndInstall () ]


reorderOperation : List String -> Msg
reorderOperation shuffledMobsters =
    (UpdateMobsterData (Mobster.Reorder shuffledMobsters))


focusAddMobsterInput : Cmd Msg
focusAddMobsterInput =
    Task.attempt DomFocusResult (Dom.focus "add-mobster")


validateTimerDuration : String -> Int -> Int
validateTimerDuration newDurationAsString oldTimerDuration =
    let
        rawDuration =
            Result.withDefault 5 (String.toInt newDurationAsString)
    in
        if rawDuration > 15 then
            15
        else if rawDuration < 1 then
            1
        else
            rawDuration


validateBreakInterval : String -> Int -> Int
validateBreakInterval newDurationAsString oldTimerDuration =
    let
        rawDuration =
            Result.withDefault 6 (String.toInt newDurationAsString)
    in
        if rawDuration > 30 then
            30
        else if rawDuration < 0 then
            0
        else
            rawDuration


init : Decode.Value -> ( Model, Cmd Msg )
init flags =
    let
        decodedMobsterData =
            Mobster.decode flags
    in
        case decodedMobsterData of
            Ok mobsterData ->
                { initialModel | mobsterData = mobsterData } ! []

            Err errorString ->
                initialModel ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Keyboard.Combo.subscriptions model.combos
        , timeElapsed TimeElapsed
        , updateDownloaded UpdateAvailable
        , onCopyMobstersShortcut CopyActiveMobsters
        ]


onEnter : Msg -> Attribute Msg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                Json.succeed msg
            else
                Json.fail "not the right keycode"
    in
        on "keydown" (keyCode |> Json.andThen isEnter)


main : Program Decode.Value Model Msg
main =
    Html.programWithFlags
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
