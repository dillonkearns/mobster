port module Setup.Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, value, type_, id, style)
import Html.Events exposing (on, keyCode, onClick, onInput, onSubmit)
import Json.Decode as Json
import Mobsters


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


type Msg
    = StartTimer
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
    , mobsterList : Mobsters.MobsterList
    , newMobster : String
    }


initialModel : Model
initialModel =
    { timerDuration = 5
    , screenState = Configure
    , mobsterList = Mobsters.empty
    , newMobster = ""
    }


type alias TimerConfiguration =
    { minutes : Int, driver : String, navigator : String }


flags : Model -> TimerConfiguration
flags model =
    let
        driverNavigator =
            Mobsters.nextDriverNavigator model.mobsterList
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
    div []
        [ button [ onClick Quit, class "btn btn-primary btn-md btn-block" ] [ text "Quit" ]
        ]


configureView : Model -> Html Msg
configureView model =
    div []
        [ h1 [ class "text-primary text-center" ] [ text "Mobster" ]
        , div [ class "text-center" ]
            [ button [ onClick StartTimer, class "btn btn-info btn-lg btn-block" ] [ text "Start Mobbing" ]
            , timerDurationInputView model.timerDuration
            , mobstersView model.newMobster model.mobsterList
            , quitButton
            ]
        ]


continueView : Model -> Html Msg
continueView model =
    h1 [ class "text-primary text-center" ]
        [ text "Mobster"
        , div [ class "text-center" ]
            [ button [ onClick StartTimer, class "btn btn-info btn-lg btn-block" ] [ text "Continue" ]
            , div [] [ button [ onClick OpenConfigure, class "btn btn-primary btn-md" ] [ text "Configure" ] ]
            , quitButton
            ]
        ]


addMobsterInputView : String -> Html Msg
addMobsterInputView newMobster =
    div []
        [ div [ class "input-group" ]
            [ input [ type_ "text", class "form-control", value newMobster, onInput UpdateMobsterInput, onEnter AddMobster ] []
            , span [ class "input-group-btn", type_ "button" ] [ button [ class "btn btn-primary", onClick AddMobster ] [ text "Add Mobster" ] ]
            ]
        ]


mobstersView : String -> Mobsters.MobsterList -> Html Msg
mobstersView newMobster mobsterList =
    div [ style [ ( "padding-bottom", "50px" ) ] ]
        [ addMobsterInputView newMobster
        , ul [] (List.map (\mobsterName -> li [] [ mobsterView mobsterName ]) mobsterList.mobsters)
        ]


mobsterView : String -> Html Msg
mobsterView mobster =
    span [] [ text mobster ]


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
                rotatedMobsterList =
                    Mobsters.rotate model.mobsterList
            in
                { model
                    | screenState = Continue
                    , mobsterList = rotatedMobsterList
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

        UpdateMobsterInput text ->
            { model | newMobster = text } ! []

        Quit ->
            model ! [ quit "" ]


addMobster : String -> Model -> Model
addMobster newMobster model =
    let
        updatedMobsterList =
            Mobsters.add
                model.newMobster
                model.mobsterList
    in
        { model | newMobster = "", mobsterList = updatedMobsterList }


main : Program Never Model Msg
main =
    Html.program
        { init = ( initialModel, Cmd.none )
        , subscriptions = \_ -> Sub.none
        , update = update
        , view = view
        }
