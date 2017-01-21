module Timer.Main exposing (..)

import Html exposing (..)
import Time exposing (..)
import Timer.Timer exposing (..)


type alias Model =
    { secondsLeft : Int }


type Msg
    = Tick Time.Time


view : Model -> Html msg
view model =
    h1 [] [ text (timerToString (secondsToTimer model.secondsLeft)) ]


updateTimer : Int -> Int
updateTimer seconds =
    seconds - 1


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick time ->
            { model | secondsLeft = (updateTimer model.secondsLeft) } ! []


initialModel : Model
initialModel =
    { secondsLeft = 300 }


main : Program Never Model Msg
main =
    Html.program
        { init = ( initialModel, Cmd.none )
        , subscriptions = \_ -> every second Tick
        , update = update
        , view = view
        }
