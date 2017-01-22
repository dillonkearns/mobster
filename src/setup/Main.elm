port module Setup.Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, value, type_)
import Html.Events exposing (onClick, onInput)


type Msg
    = StartTimer
    | ChangeTimerDuration String


type alias Model =
    Int


type alias TimerConfiguration =
    { minutes : Int, driver : String, navigator : String }


flags : Model -> TimerConfiguration
flags model =
    { minutes = model, driver = "Hello", navigator = "World" }


port starttimer : TimerConfiguration -> Cmd msg


timerDurationInputView : a -> Html Msg
timerDurationInputView duration =
    input [ onInput ChangeTimerDuration, type_ "number", Html.Attributes.min "1", Html.Attributes.max "15", value (toString duration) ] []


view : Model -> Html Msg
view model =
    h1 [ class "text-primary text-center" ]
        [ text "Mobster"
        , div [ class "text-center" ]
            [ button [ onClick StartTimer, class "btn btn-primary btn-lg" ] [ text "Start Mobbing" ]
            , div []
                [ timerDurationInputView model
                , text "Minutes"
                ]
            ]
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        StartTimer ->
            model
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
                duration ! []


main : Program Never Model Msg
main =
    Html.program
        { init = ( 5, Cmd.none )
        , subscriptions = \_ -> Sub.none
        , update = update
        , view = view
        }
