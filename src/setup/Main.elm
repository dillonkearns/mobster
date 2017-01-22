port module Setup.Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, value, type_, id)
import Html.Events exposing (onClick, onInput)


type Msg
    = StartTimer
    | ChangeTimerDuration String
    | SelectDurationInput
    | OpenConfigure


type ScreenState
    = Configure
    | Continue


type alias Model =
    { timerDuration : Int, screenState : ScreenState }


type alias TimerConfiguration =
    { minutes : Int, driver : String, navigator : String }


flags : Model -> TimerConfiguration
flags model =
    { minutes = model.timerDuration, driver = "Hello", navigator = "World" }


port starttimer : TimerConfiguration -> Cmd msg


port selectduration : String -> Cmd msg


timerDurationInputView : Int -> Html Msg
timerDurationInputView duration =
    input
        [ id "timer-duration"
        , onClick SelectDurationInput
        , onInput ChangeTimerDuration
        , type_ "number"
        , Html.Attributes.min "1"
        , Html.Attributes.max "15"
        , value (toString duration)
        ]
        []


configureView : Model -> Html Msg
configureView model =
    h1 [ class "text-primary text-center" ]
        [ text "Mobster"
        , div [ class "text-center" ]
            [ button [ onClick StartTimer, class "btn btn-primary btn-lg" ] [ text "Start Mobbing" ]
            , div []
                [ timerDurationInputView model.timerDuration
                , text "Minutes"
                ]
            ]
        ]


continueView : Model -> Html Msg
continueView model =
    h1 [ class "text-primary text-center" ]
        [ text "Mobster"
        , div [ class "text-center" ]
            [ button [ onClick StartTimer, class "btn btn-primary btn-lg" ] [ text "Continue" ]
            , div [] [ button [ onClick OpenConfigure, class "btn btn-primary btn-md" ] [ text "Configure" ] ]
            ]
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
            { model | screenState = Continue }
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


main : Program Never Model Msg
main =
    Html.program
        { init = ( { timerDuration = 5, screenState = Configure }, Cmd.none )
        , subscriptions = \_ -> Sub.none
        , update = update
        , view = view
        }
