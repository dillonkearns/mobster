port module Setup.Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, value, type_, id, style, src, title, href, target, placeholder)
import Html.Events exposing (on, keyCode, onClick, onInput, onSubmit)
import Json.Decode as Json
import Task
import Dom
import Mobster exposing (MoblistOperation)
import Json.Decode as Decode
import Keyboard.Combo
import Random
import Tip
import Setup.PlotScatter
import Svg


shuffleMobstersCmd : Mobster.MobsterData -> Cmd Msg
shuffleMobstersCmd mobsterData =
    Random.generate ReorderMobsters (Mobster.randomizeMobsters mobsterData)


type Msg
    = StartTimer
    | UpdateMoblist MoblistOperation
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
    | ReorderMobsters (List String)
    | ShuffleMobsters
    | TimeElapsed Int


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
    , tip : Tip.Tip Msg
    , goal : Maybe String
    , newGoal : String
    , ratings : List Int
    , elapsedSeconds : Int
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
    , elapsedSeconds = 0
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


port timeElapsed : (Int -> msg) -> Sub msg


timerDurationInputView : Int -> Html Msg
timerDurationInputView duration =
    div [ class "text-primary h1" ]
        [ input
            [ id "timer-duration"
            , onClick SelectDurationInput
            , onInput ChangeTimerDuration
            , type_ "number"
            , Html.Attributes.min "1"
            , Html.Attributes.max "15"
            , value (toString duration)
            , class "right-buffer"
            , style [ ( "font-size", "60px" ) ]
            ]
            []
        , text "Minutes"
        ]


quitButton : Html Msg
quitButton =
    button [ onClick Quit, class "btn btn-primary btn-md btn-block" ] [ text "Quit" ]


titleTextView : Html msg
titleTextView =
    h1 [ class "text-info text-center", id "mobster-title", style [ ( "font-size", "62px" ) ] ] [ text "Mobster" ]


invisibleTrigger : Html msg
invisibleTrigger =
    img [ src "./assets/invisible.png", class "invisible-trigger pull-left", style [ ( "max-width", "35px" ) ] ] []


configureView : Model -> Html Msg
configureView model =
    div [ class "container-fluid" ]
        [ div [ class "row" ]
            [ invisibleTrigger
            , titleTextView
            ]
        , button [ onClick StartTimer, class "btn btn-info btn-lg btn-block top-buffer", title "Ctrl+Enter or ⌘+Enter", style [ ( "font-size", "30px" ), ( "padding", "20px" ) ] ] [ text "Start Mobbing" ]
        , div [ class "row" ]
            [ div [ class "col-md-4" ] [ timerDurationInputView model.timerDuration ]
            , div [ class "col-md-4" ] [ mobstersView model.newMobster (Mobster.mobsters model.mobsterData) ]
            , div [ class "col-md-4" ] [ inactiveMobstersView model.mobsterData.inactiveMobsters ]
            ]
        , div [ class "h1" ] [ goalView model.newGoal model.goal ]
        , div [ class "row top-buffer" ] [ quitButton ]
        ]


goalView : String -> Maybe String -> Html Msg
goalView newGoal maybeGoal =
    case maybeGoal of
        Just goal ->
            div [] [ text goal, button [ onClick ChangeGoal, class "btn btn-sm btn-primary" ] [ text "Edit goal" ] ]

        Nothing ->
            div [ class "input-group" ]
                [ input [ id "add-mobster", placeholder "Please give me a goal", type_ "text", class "form-control", value newGoal, onInput UpdateGoalInput, onEnter SetGoal, style [ ( "font-size", "30px" ) ] ] []
                , span [ class "input-group-btn", type_ "button" ] [ button [ class "btn btn-primary", onClick SetGoal ] [ text "Set Goal" ] ]
                ]


continueButtonChildren : Model -> List (Html Msg)
continueButtonChildren model =
    case model.goal of
        Just goalText ->
            [ div [ class "col-md-4" ] [ text "Continue" ]
            , div
                [ class "col-md-8"
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
breakSuggested elapsedSeconds =
    elapsedSeconds >= 24 * 60


breakView : Int -> Html msg
breakView elapsedSeconds =
    let
        elapsedMinutes =
            elapsedSeconds // 60
    in
        if breakSuggested elapsedSeconds then
            div [ class "alert alert-warning alert-dismissible", style [ ( "font-size", "20px" ) ] ]
                [ span [ class "glyphicon glyphicon-exclamation-sign right-buffer" ] []
                , text ("How about a walk? (You've been mobbing for " ++ (toString elapsedMinutes) ++ " minutes.)")
                ]
        else
            div [] []


continueView : Model -> Html Msg
continueView model =
    div [ class "container-fluid" ]
        [ div [ class "row" ]
            [ invisibleTrigger
            , titleTextView
            ]
        , ratingsView model
        , breakView model.elapsedSeconds
        , div [ class "row", style [ ( "padding-bottom", "20px" ) ] ]
            [ button
                [ onClick StartTimer
                , class "btn btn-info btn-lg btn-block top-buffer"
                , title "Ctrl+Enter or ⌘+Enter"
                , style [ ( "font-size", "30px" ), ( "padding", "20px" ) ]
                ]
                (continueButtonChildren model)
            ]
        , nextDriverNavigatorView model
        , tipView model.tip
        , div [ class "row top-buffer", style [ ( "padding-bottom", "20px" ) ] ] [ button [ onClick OpenConfigure, class "btn btn-primary btn-md btn-block" ] [ text "Configure" ] ]
        , div [ class "row top-buffer" ] [ quitButton ]
        ]


tipView : Tip.Tip Msg -> Html Msg
tipView tip =
    div [ class "jumbotron tip", style [ ( "margin", "0px" ), ( "padding", "25px" ) ] ]
        [ div [ class "row" ]
            [ h2 [ class "text-success pull-left", style [ ( "margin", "0px" ), ( "padding-bottom", "10px" ) ] ]
                [ text tip.title ]
            , a [ target "_blank", class "btn btn-sm btn-primary pull-right", href tip.url ] [ text "Learn More" ]
            ]
        , div [ class "row", style [ ( "font-size", "20px" ) ] ] [ tip.body ]
        ]


nextDriverNavigatorView : Model -> Html Msg
nextDriverNavigatorView model =
    let
        driverNavigator =
            Mobster.nextDriverNavigator model.mobsterData
    in
        div [ class "row h1" ]
            [ div [ class "text-muted col-md-3" ] [ text "Next:" ]
            , dnView driverNavigator.driver Mobster.Driver
            , dnView driverNavigator.navigator Mobster.Navigator
            , button [ class "btn btn-small btn-default", onClick (UpdateMoblist Mobster.SkipTurn) ] [ text "Skip Turn" ]
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
        div [ class "col-md-4 text-default" ]
            [ iconView icon 40
            , span [ class "right-buffer" ] [ text mobster.name ]
            , button [ onClick (UpdateMoblist (Mobster.Bench mobster.index)), class "btn btn-small btn-default" ] [ text "Not here" ]
            ]


iconView : String -> Int -> Html msg
iconView iconUrl maxWidth =
    img [ style [ ( "max-width", (toString maxWidth) ++ "px" ), ( "margin-right", "8px" ) ], src iconUrl ] []


nextView : String -> String -> Html msg
nextView thing name =
    span []
        [ span [ class "text-muted" ] [ text ("Next " ++ thing ++ ": ") ]
        , span [ class "text-info" ] [ text name ]
        ]


addMobsterInputView : String -> Html Msg
addMobsterInputView newMobster =
    div [ class "row top-buffer" ]
        [ div [ class "input-group" ]
            [ input [ id "add-mobster", Html.Attributes.placeholder "Jane Doe", type_ "text", class "form-control", value newMobster, onInput UpdateMobsterInput, onEnter AddMobster, style [ ( "font-size", "30px" ) ] ] []
            , span [ class "input-group-btn", type_ "button" ] [ button [ class "btn btn-primary", onClick ClickAddMobster ] [ text "Add Mobster" ] ]
            ]
        ]


mobstersView : String -> List Mobster.MobsterWithRole -> Html Msg
mobstersView newMobster mobsters =
    div [ style [ ( "padding-bottom", "35px" ) ] ]
        [ addMobsterInputView newMobster
        , img [ onClick ShuffleMobsters, class "top-buffer shuffle", src "./assets/dice.png", style [ ( "max-width", "25px" ) ] ] []
        , table [ class "table h3" ] (List.map mobsterView mobsters)
        ]


inactiveMobstersView : List String -> Html Msg
inactiveMobstersView inactiveMobsters =
    div []
        [ h2 [ class "text-center text-primary" ] [ text "Bench" ]
        , table [ class "table h3" ] (List.indexedMap inactiveMobsterView inactiveMobsters)
        ]


inactiveMobsterView : Int -> String -> Html Msg
inactiveMobsterView mobsterIndex inactiveMobster =
    tr []
        [ td [] []
        , td [ style [ ( "width", "200px" ), ( "min-width", "200px" ), ( "text-align", "right" ), ( "padding-right", "10px" ) ] ]
            [ span [ class "inactive-mobster", onClick (UpdateMoblist (Mobster.RotateIn mobsterIndex)) ] [ text inactiveMobster ]
            , div [ class "btn-group btn-group-xs", style [ ( "margin-left", "10px" ) ] ]
                [ button [ class "btn btn-small btn-danger", onClick (UpdateMoblist (Mobster.Remove mobsterIndex)) ] [ text "x" ]
                ]
            ]
        ]


mobsterView : Mobster.MobsterWithRole -> Html Msg
mobsterView mobster =
    tr []
        [ td [] []
        , td [ style [ ( "width", "200px" ), ( "min-width", "200px" ), ( "text-align", "right" ), ( "padding-right", "10px" ) ] ]
            [ span [ Html.Attributes.classList [ ( "text-primary", mobster.role == Just Mobster.Driver ) ], class "active-mobster", onClick (UpdateMoblist (Mobster.SetNextDriver mobster.index)) ]
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
            span [ class "role-icon driver-icon" ] []

        Just (Mobster.Navigator) ->
            span [ class "role-icon navigator-icon" ] []

        Nothing ->
            span [ class "role-icon no-role-icon" ] []


reorderButtonView : Mobster.MobsterWithRole -> Html Msg
reorderButtonView mobster =
    let
        mobsterIndex =
            mobster.index
    in
        div []
            [ div [ class "btn-group btn-group-xs" ]
                [ button [ class "btn btn-small btn-default", onClick (UpdateMoblist (Mobster.MoveUp mobsterIndex)) ] [ text "↑" ]
                , button [ class "btn btn-small btn-default", onClick (UpdateMoblist (Mobster.MoveDown mobsterIndex)) ] [ text "↓" ]
                , button [ class "btn btn-small btn-default", onClick (UpdateMoblist (Mobster.Bench mobsterIndex)) ] [ text "x" ]
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
            if breakSuggested model.elapsedSeconds then
                0
            else
                model.elapsedSeconds
    in
        { model | elapsedSeconds = updatedElapsedSeconds }


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
                let
                    updatedModel =
                        (addMobster model.newMobster model)
                in
                    updatedModel ! [ saveSetup updatedModel.mobsterData ]

        ClickAddMobster ->
            if model.newMobster == "" then
                model ! []
            else
                let
                    command =
                        Task.attempt DomFocusResult (Dom.focus "add-mobster")

                    updatedModel =
                        (addMobster model.newMobster model)
                in
                    updatedModel ! [ command, saveSetup updatedModel.mobsterData ]

        DomFocusResult _ ->
            model ! []

        UpdateMoblist operation ->
            let
                updatedMobsterData =
                    Mobster.updateMoblist operation model.mobsterData
            in
                { model
                    | mobsterData = updatedMobsterData
                }
                    ! [ saveSetup updatedMobsterData ]

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

        ReorderMobsters shuffledMobsters ->
            { model | mobsterData = (model.mobsterData |> Mobster.reorder shuffledMobsters) } ! []

        ShuffleMobsters ->
            model ! [ shuffleMobstersCmd model.mobsterData ]

        TimeElapsed elapsedSeconds ->
            let
                updatedElapsedSeconds =
                    model.elapsedSeconds + elapsedSeconds
            in
                { model | elapsedSeconds = updatedElapsedSeconds } ! []


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


addMobster : String -> Model -> Model
addMobster newMobster model =
    let
        updatedMobsterData =
            Mobster.add
                model.newMobster
                model.mobsterData
    in
        { model | newMobster = "", mobsterData = updatedMobsterData }


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
