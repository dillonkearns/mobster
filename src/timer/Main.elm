module Timer.Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (src, style, class)
import Time exposing (..)
import Timer.Timer exposing (..)


type alias Model =
    { secondsLeft : Int }


type Msg
    = Tick Time.Time


driverView : Html msg
driverView =
    p []
        [ iconView "./assets/driver-icon.png"
        , text "Jane"
        ]


navigatorView : Html msg
navigatorView =
    p []
        [ iconView "./assets/navigator-icon.png"
        , text "John"
        ]


iconView : String -> Html msg
iconView iconUrl =
    img [ style [ ( "max-width", "20px" ) ], src iconUrl ] []


view : Model -> Html msg
view model =
    div [ class "text-center" ]
        [ h1 [] [ text (timerToString (secondsToTimer model.secondsLeft)) ]
        , driverView
        , navigatorView
        ]


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
