port module Setup.Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (value, type_, id, style, src, title, href, target, placeholder)
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
    | SelectDurationInput
    | OpenConfigure
    | NewTip Int
    | SetGoal
    | ChangeGoal
    | UpdateGoalInput String
    | EnterRating Int
    | Quit
    | ComboMsg Keyboard.Combo.Msg
    | ShuffleMobsters
    | TimeElapsed Int
    | CopyActiveMobsters ()


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
    , goal : Maybe String
    , newGoal : String
    , ratings : List Int
    , secondsSinceBreak : Int
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
    , goal = Nothing
    , newGoal = ""
    , ratings = []
    , secondsSinceBreak = 0
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


port selectDuration : String -> Cmd msg


port copyActiveMobsters : String -> Cmd msg


port timeElapsed : (Int -> msg) -> Sub msg


port onCopyMobstersShortcut : (() -> msg) -> Sub msg


timerDurationInputView : Int -> Html Msg
timerDurationInputView duration =
    div [ Html.Attributes.class "text-primary h1" ]
        [ input
            [ id "timer-duration"
            , onClick SelectDurationInput
            , onInput ChangeTimerDuration
            , type_ "number"
            , Html.Attributes.min "1"
            , Html.Attributes.max "15"
            , value (toString duration)
            , Html.Attributes.class "right-buffer"
            , style [ ( "font-size", "60px" ) ]
            ]
            []
        , text "Minutes"
        ]


quitButton : Html Msg
quitButton =
    button [ onClick Quit, Html.Attributes.class "btn btn-primary btn-md btn-block" ] [ text "Quit" ]


titleTextView : Html msg
titleTextView =
    h1 [ Html.Attributes.class "text-info text-center", id "mobster-title", style [ ( "font-size", "62px" ) ] ] [ text "Mobster" ]


invisibleTrigger : Html msg
invisibleTrigger =
    img [ src "./assets/invisible.png", Html.Attributes.class "invisible-trigger pull-left", style [ ( "max-width", "35px" ) ] ] []


configureView : Model -> Html Msg
configureView model =
    div [ Html.Attributes.class "container-fluid" ]
        [ div [ Html.Attributes.class "row" ]
            [ invisibleTrigger
            , titleTextView
            ]
        , button [ onClick StartTimer, Html.Attributes.class "btn btn-info btn-lg btn-block", class [ BufferTop ], title "Ctrl+Enter or ⌘+Enter", style [ ( "font-size", "30px" ), ( "padding", "20px" ) ] ] [ text "Start Mobbing" ]
        , div [ Html.Attributes.class "row" ]
            [ div [ Html.Attributes.class "col-md-4" ] [ timerDurationInputView model.timerDuration ]
            , div [ Html.Attributes.class "col-md-4" ] [ mobstersView model.newMobster (Mobster.mobsters model.mobsterData) ]
            , div [ Html.Attributes.class "col-md-4" ] [ inactiveMobstersView model.mobsterData.inactiveMobsters ]
            ]
        , div [ Html.Attributes.class "h1" ] [ goalView model.newGoal model.goal ]
        , div [ Html.Attributes.class "row", class [ BufferTop ] ] [ quitButton ]
        ]


goalView : String -> Maybe String -> Html Msg
goalView newGoal maybeGoal =
    case maybeGoal of
        Just goal ->
            div [] [ text goal, button [ onClick ChangeGoal, Html.Attributes.class "btn btn-sm btn-primary" ] [ text "Edit goal" ] ]

        Nothing ->
            div [ Html.Attributes.class "input-group" ]
                [ input [ id "add-mobster", placeholder "Please give me a goal", type_ "text", Html.Attributes.class "form-control", value newGoal, onInput UpdateGoalInput, onEnter SetGoal, style [ ( "font-size", "30px" ) ] ] []
                , span [ Html.Attributes.class "input-group-btn", type_ "button" ] [ button [ Html.Attributes.class "btn btn-primary", onClick SetGoal ] [ text "Set Goal" ] ]
                ]


continueButtonChildren : Model -> List (Html Msg)
continueButtonChildren model =
    case model.goal of
        Just goalText ->
            [ div [ Html.Attributes.class "col-md-4" ] [ text "Continue" ]
            , div
                [ Html.Attributes.class "col-md-8"
                , style
                    [ ( "font-size", "22px" )
                    , ( "font-style", "italic" )
                    , ( "text-align", "left" )
                    ]
                ]
                [ text goalText ]
            ]

        Nothing ->
            [ div [] [ text "Continue" ] ]


ratingsToPlotData : List Int -> List ( Float, Float )
ratingsToPlotData ratings =
    List.indexedMap (\index value -> ( toFloat index, toFloat value )) ratings


ratingsView : Model -> Svg.Svg Msg
ratingsView model =
    case model.goal of
        Just _ ->
            if List.length model.ratings > 0 then
                Setup.PlotScatter.view (ratingsToPlotData model.ratings)
            else
                div [] []

        Nothing ->
            div [] []


breakSuggested : Int -> Bool
breakSuggested secondsSinceBreak =
    secondsSinceBreak >= 24 * 60


breakView : Int -> Html msg
breakView secondsSinceBreak =
    let
        minutesSinceBreak =
            secondsSinceBreak // 60
    in
        if breakSuggested secondsSinceBreak then
            div [ Html.Attributes.class "alert alert-warning alert-dismissible", style [ ( "font-size", "20px" ) ] ]
                [ span [ Html.Attributes.class "glyphicon glyphicon-exclamation-sign right-buffer" ] []
                , text ("How about a walk? (You've been mobbing for " ++ (toString minutesSinceBreak) ++ " minutes.)")
                ]
        else
            div [] []


continueView : Model -> Html Msg
continueView model =
    div [ Html.Attributes.class "container-fluid" ]
        [ div [ Html.Attributes.class "row" ]
            [ invisibleTrigger
            , titleTextView
            ]
        , ratingsView model
        , breakView model.secondsSinceBreak
        , div [ Html.Attributes.class "row", style [ ( "padding-bottom", "20px" ) ] ]
            [ button
                [ onClick StartTimer
                , Html.Attributes.class "btn btn-info btn-lg btn-block"
                , class [ BufferTop ]
                , title "Ctrl+Enter or ⌘+Enter"
                , style [ ( "font-size", "30px" ), ( "padding", "20px" ) ]
                ]
                (continueButtonChildren model)
            ]
        , nextDriverNavigatorView model
        , tipView model.tip
        , div [ Html.Attributes.class "row", class [ BufferTop ], style [ ( "padding-bottom", "20px" ) ] ] [ button [ onClick OpenConfigure, Html.Attributes.class "btn btn-primary btn-md btn-block" ] [ text "Configure" ] ]
        , div [ Html.Attributes.class "row", class [ BufferTop ] ] [ quitButton ]
        ]


tipView : Tip.Tip -> Html Msg
tipView tip =
    div [ Html.Attributes.class "jumbotron tip", style [ ( "margin", "0px" ), ( "padding", "25px" ) ] ]
        [ div [ Html.Attributes.class "row" ]
            [ h2 [ Html.Attributes.class "text-success pull-left", style [ ( "margin", "0px" ), ( "padding-bottom", "10px" ) ] ]
                [ text tip.title ]
            , a [ target "_blank", Html.Attributes.class "btn btn-sm btn-primary pull-right", href tip.url ] [ text "Learn More" ]
            ]
        , div [ Html.Attributes.class "row", style [ ( "font-size", "20px" ) ] ] [ Tip.tipView tip ]
        ]


nextDriverNavigatorView : Model -> Html Msg
nextDriverNavigatorView model =
    let
        driverNavigator =
            Mobster.nextDriverNavigator model.mobsterData
    in
        div [ Html.Attributes.class "row h1" ]
            [ div [ Html.Attributes.class "text-muted col-md-3" ] [ text "Next:" ]
            , dnView driverNavigator.driver Mobster.Driver
            , dnView driverNavigator.navigator Mobster.Navigator
            , button [ Html.Attributes.class "btn btn-small btn-default", onClick (UpdateMobsterData Mobster.SkipTurn) ] [ text "Skip Turn" ]
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
        div [ Html.Attributes.class "col-md-4 text-default" ]
            [ iconView icon 40
            , span [ Html.Attributes.class "right-buffer" ] [ text mobster.name ]
            , button [ onClick (UpdateMobsterData (Mobster.Bench mobster.index)), Html.Attributes.class "btn btn-small btn-default" ] [ text "Not here" ]
            ]


iconView : String -> Int -> Html msg
iconView iconUrl maxWidth =
    img [ style [ ( "max-width", (toString maxWidth) ++ "px" ), ( "margin-right", "8px" ) ], src iconUrl ] []


nextView : String -> String -> Html msg
nextView thing name =
    span []
        [ span [ Html.Attributes.class "text-muted" ] [ text ("Next " ++ thing ++ ": ") ]
        , span [ Html.Attributes.class "text-info" ] [ text name ]
        ]


addMobsterInputView : String -> Html Msg
addMobsterInputView newMobster =
    div [ Html.Attributes.class "row", class [ BufferTop ] ]
        [ div [ Html.Attributes.class "input-group" ]
            [ input [ id "add-mobster", Html.Attributes.placeholder "Jane Doe", type_ "text", Html.Attributes.class "form-control", value newMobster, onInput UpdateMobsterInput, onEnter AddMobster, style [ ( "font-size", "30px" ) ] ] []
            , span [ Html.Attributes.class "input-group-btn", type_ "button" ] [ button [ Html.Attributes.class "btn btn-primary", onClick ClickAddMobster ] [ text "Add Mobster" ] ]
            ]
        ]


mobstersView : String -> List Mobster.MobsterWithRole -> Html Msg
mobstersView newMobster mobsters =
    div [ style [ ( "padding-bottom", "35px" ) ] ]
        [ addMobsterInputView newMobster
        , img [ onClick ShuffleMobsters, Html.Attributes.class "shuffle", class [ BufferTop ], src "./assets/dice.png", style [ ( "max-width", "25px" ) ] ] []
        , table [ Html.Attributes.class "table h3" ] (List.map mobsterView mobsters)
        ]


inactiveMobstersView : List String -> Html Msg
inactiveMobstersView inactiveMobsters =
    div []
        [ h2 [ Html.Attributes.class "text-center text-primary" ] [ text "Bench" ]
        , table [ Html.Attributes.class "table h3" ] (List.indexedMap inactiveMobsterView inactiveMobsters)
        ]


inactiveMobsterView : Int -> String -> Html Msg
inactiveMobsterView mobsterIndex inactiveMobster =
    tr []
        [ td [] []
        , td [ style [ ( "width", "200px" ), ( "min-width", "200px" ), ( "text-align", "right" ), ( "padding-right", "10px" ) ] ]
            [ span [ Html.Attributes.class "inactive-mobster", onClick (UpdateMobsterData (Mobster.RotateIn mobsterIndex)) ] [ text inactiveMobster ]
            , div [ Html.Attributes.class "btn-group btn-group-xs", style [ ( "margin-left", "10px" ) ] ]
                [ button [ Html.Attributes.class "btn btn-small btn-danger", onClick (UpdateMobsterData (Mobster.Remove mobsterIndex)) ] [ text "x" ]
                ]
            ]
        ]


mobsterView : Mobster.MobsterWithRole -> Html Msg
mobsterView mobster =
    tr []
        [ td [] []
        , td [ style [ ( "width", "200px" ), ( "min-width", "200px" ), ( "text-align", "right" ), ( "padding-right", "10px" ) ] ]
            [ span [ Html.Attributes.classList [ ( "text-primary", mobster.role == Just Mobster.Driver ) ], Html.Attributes.class "active-mobster", onClick (UpdateMobsterData (Mobster.SetNextDriver mobster.index)) ]
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
            span [ Html.Attributes.class "role-icon driver-icon" ] []

        Just (Mobster.Navigator) ->
            span [ Html.Attributes.class "role-icon navigator-icon" ] []

        Nothing ->
            span [ Html.Attributes.class "role-icon no-role-icon" ] []


reorderButtonView : Mobster.MobsterWithRole -> Html Msg
reorderButtonView mobster =
    let
        mobsterIndex =
            mobster.index
    in
        div []
            [ div [ Html.Attributes.class "btn-group btn-group-xs" ]
                [ button [ Html.Attributes.class "btn btn-small btn-default", onClick (UpdateMobsterData (Mobster.MoveUp mobsterIndex)) ] [ text "↑" ]
                , button [ Html.Attributes.class "btn btn-small btn-default", onClick (UpdateMobsterData (Mobster.MoveDown mobsterIndex)) ] [ text "↓" ]
                , button [ Html.Attributes.class "btn btn-small btn-default", onClick (UpdateMobsterData (Mobster.Bench mobsterIndex)) ] [ text "x" ]
                ]
            ]


view : Model -> Html Msg
view model =
    case model.screenState of
        Configure ->
            configureView model

        Continue ->
            continueView model


resetIfAfterBreak : Model -> Model
resetIfAfterBreak model =
    let
        updatedElapsedSeconds =
            if breakSuggested model.secondsSinceBreak then
                0
            else
                model.secondsSinceBreak
    in
        { model | secondsSinceBreak = updatedElapsedSeconds }


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

        SetGoal ->
            if model.newGoal == "" then
                model ! []
            else
                { model | goal = Just model.newGoal } ! []

        UpdateGoalInput newGoal ->
            { model | newGoal = newGoal } ! []

        ChangeGoal ->
            { model | goal = Nothing } ! []

        EnterRating rating ->
            update StartTimer { model | ratings = model.ratings ++ [ rating ] }

        ShuffleMobsters ->
            model ! [ shuffleMobstersCmd model.mobsterData ]

        TimeElapsed elapsedSeconds ->
            { model | secondsSinceBreak = (model.secondsSinceBreak + elapsedSeconds) } ! []

        CopyActiveMobsters _ ->
            model ! [ (copyActiveMobsters (String.join ", " model.mobsterData.mobsters)) ]


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
