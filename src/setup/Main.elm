port module Setup.Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, value, type_, id, style, src)
import Html.Events exposing (on, keyCode, onClick, onInput, onSubmit)
import Json.Decode as Json
import Mobster


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


type ReorderDirection
    = Up
    | Down


type Msg
    = StartTimer
    | Move ReorderDirection Int
    | RemoveMobster Int
    | SetNextDriver Int
    | UpdateMobsterInput String
    | AddMobster
    | ChangeTimerDuration String
    | SelectDurationInput
    | OpenConfigure
    | Quit


type ScreenState
    = Configure
    | Continue


type alias Model =
    { timerDuration : Int
    , screenState : ScreenState
    , mobsterList : Mobster.MobsterData
    , newMobster : String
    }


initialModel : Model
initialModel =
    { timerDuration = 5
    , screenState = Configure
    , mobsterList = Mobster.empty
    , newMobster = ""
    }


type alias TimerConfiguration =
    { minutes : Int, driver : String, navigator : String }


flags : Model -> TimerConfiguration
flags model =
    let
        driverNavigator =
            Mobster.nextDriverNavigator model.mobsterList
    in
        { minutes = model.timerDuration
        , driver = driverNavigator.driver
        , navigator = driverNavigator.navigator
        }


port starttimer : TimerConfiguration -> Cmd msg


port quit : String -> Cmd msg


port selectduration : String -> Cmd msg


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
            ]
            []
        , text "Minutes"
        ]


quitButton : Html Msg
quitButton =
    button [ onClick Quit, class "btn btn-primary btn-md btn-block" ] [ text "Quit" ]


titleTextView : Html msg
titleTextView =
    h1 [ class "text-primary text-center", id "mobster-title" ] [ text "Mobster" ]


invisibleTrigger : Html msg
invisibleTrigger =
    img [ src "./assets/invisible.png", class "invisible-trigger", style [ ( "max-width", "30px" ) ] ] []


configureView : Model -> Html Msg
configureView model =
    div [ class "container-fluid" ]
        [ invisibleTrigger
        , titleTextView
        , button [ onClick StartTimer, class "btn btn-info btn-lg btn-block" ] [ text "Start Mobbing" ]
        , timerDurationInputView model.timerDuration
        , mobstersView model.newMobster (Mobster.mobsters model.mobsterList)
        , div [ class "row top-buffer" ] [ quitButton ]
        ]


continueView : Model -> Html Msg
continueView model =
    div [ class "container-fluid" ]
        [ invisibleTrigger
        , titleTextView
        , div [ class "row" ]
            [ button [ onClick StartTimer, class "btn btn-info btn-lg btn-block" ] [ text "Continue" ]
            ]
        , nextDriverNavigatorView model
        , div [ class "row top-buffer" ] [ button [ onClick OpenConfigure, class "btn btn-primary btn-md btn-block" ] [ text "Configure" ] ]
        , div [ class "row top-buffer" ] [ quitButton ]
        ]


nextDriverNavigatorView : Model -> Html msg
nextDriverNavigatorView model =
    let
        driverNavigator =
            Mobster.nextDriverNavigator model.mobsterList
    in
        div [ class "row h1" ]
            [ div [ class "text-muted col-md-4" ] [ text "Next:" ]
            , driverView driverNavigator.driver
            , navigatorView driverNavigator.navigator
            ]


driverView : String -> Html msg
driverView name =
    div [ class "col-md-4 text-success" ]
        [ iconView "./assets/driver-icon.png" 40
        , text name
        ]


navigatorView : String -> Html msg
navigatorView name =
    div [ class "col-md-4 text-success" ]
        [ iconView "./assets/navigator-icon.png" 40
        , text name
        ]


iconView : String -> Int -> Html msg
iconView iconUrl maxWidth =
    img [ style [ ( "max-width", (toString maxWidth) ++ "px" ) ], src iconUrl ] []


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
            [ input [ type_ "text", class "form-control", value newMobster, onInput UpdateMobsterInput, onEnter AddMobster ] []
            , span [ class "input-group-btn", type_ "button" ] [ button [ class "btn btn-primary", onClick AddMobster ] [ text "Add Mobster" ] ]
            ]
        ]


mobstersView : String -> Mobster.Mobsters -> Html Msg
mobstersView newMobster mobsters =
    div [ style [ ( "padding-bottom", "50px" ) ] ]
        [ addMobsterInputView newMobster
        , table [ class "table" ] (List.map mobsterView mobsters)
        ]


mobsterView : Mobster.Mobster -> Html Msg
mobsterView mobster =
    tr []
        [ td [] [ roleView mobster.role ]
        , td [ style [ ( "width", "200px" ), ( "min-width", "200px" ), ( "text-align", "right" ), ( "padding-right", "10px" ) ] ] [ text mobster.name ]
        , td [] [ reorderButtonView mobster.index ]
        ]


roleView : Maybe Mobster.Role -> Html Msg
roleView role =
    case role of
        Just (Mobster.Driver) ->
            iconView "./assets/driver-icon.png" 20

        Just (Mobster.Navigator) ->
            iconView "./assets/navigator-icon.png" 20

        Nothing ->
            span [] []


reorderButtonView : Int -> Html Msg
reorderButtonView mobsterIndex =
    div [ class "btn-group btn-group-xs" ]
        [ button [ class "btn btn-small btn-default", onClick (Move Up mobsterIndex) ] [ text "↑" ]
        , button [ class "btn btn-small btn-default", onClick (Move Down mobsterIndex) ] [ text "↓" ]
        , button [ class "btn btn-small btn-danger", onClick (RemoveMobster mobsterIndex) ] [ text "x" ]
        , button [ class "btn btn-small btn-default", onClick (SetNextDriver mobsterIndex) ] [ text "Drive" ]
        ]


view : Model -> Html Msg
view model =
    case model.screenState of
        Configure ->
            configureView model

        Continue ->
            continueView model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        StartTimer ->
            let
                rotatedMobsterData =
                    Mobster.rotate model.mobsterList
            in
                { model
                    | screenState = Continue
                    , mobsterList = rotatedMobsterData
                }
                    ! [ (starttimer (flags model)) ]

        ChangeTimerDuration durationAsString ->
            let
                rawDuration =
                    Result.withDefault 5 (String.toInt durationAsString)

                duration =
                    if rawDuration > 15 then
                        15
                    else if rawDuration < 1 then
                        1
                    else
                        rawDuration
            in
                { model | timerDuration = duration } ! []

        SelectDurationInput ->
            model ! [ selectduration "timer-duration" ]

        OpenConfigure ->
            { model | screenState = Configure } ! []

        AddMobster ->
            if model.newMobster == "" then
                model ! []
            else
                (addMobster model.newMobster model) ! []

        RemoveMobster index ->
            let
                updatedMobsterData =
                    (Mobster.remove index model.mobsterList)
            in
                { model | mobsterList = updatedMobsterData } ! []

        SetNextDriver index ->
            let
                updatedMobsterData =
                    (Mobster.setNextDriver index model.mobsterList)
            in
                { model | mobsterList = updatedMobsterData } ! []

        Move direction mobsterIndex ->
            let
                updatedMobsterData =
                    case direction of
                        Up ->
                            Mobster.moveUp mobsterIndex model.mobsterList

                        Down ->
                            Mobster.moveDown mobsterIndex model.mobsterList
            in
                { model | mobsterList = updatedMobsterData } ! []

        UpdateMobsterInput text ->
            { model | newMobster = text } ! []

        Quit ->
            model ! [ quit "" ]


addMobster : String -> Model -> Model
addMobster newMobster model =
    let
        updatedMobsterData =
            Mobster.add
                model.newMobster
                model.mobsterList
    in
        { model | newMobster = "", mobsterList = updatedMobsterData }


main : Program Never Model Msg
main =
    Html.program
        { init = ( initialModel, Cmd.none )
        , subscriptions = \_ -> Sub.none
        , update = update
        , view = view
        }
