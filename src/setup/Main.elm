port module Setup.Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)


type Msg
    = StartTimer


type alias Model =
    Int


type alias TimerConfiguration =
    { minutes : Int, driver : String, navigator : String }


flags : TimerConfiguration
flags =
    { minutes = 2, driver = "Hello", navigator = "World" }


port starttimer : TimerConfiguration -> Cmd msg


view : Model -> Html Msg
view model =
    h1 [ class "text-primary text-center" ]
        [ text "Mobster"
        , div [ class "text-center" ]
            [ button [ onClick StartTimer, class "btn btn-primary btn-lg" ] [ text "Start Mobbing" ]
            ]
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        StartTimer ->
            model
                ! [ (starttimer flags) ]


main : Program Never Model Msg
main =
    Html.program
        { init = ( 0, Cmd.none )
        , subscriptions = \_ -> Sub.none
        , update = update
        , view = view
        }
