module Timer.Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (src, style, class)
import Time exposing (..)
import Timer.Timer exposing (..)


type alias Model =
    { driver : String, navigator : String, secondsLeft : Int }


type Msg
    = Tick Time.Time


type alias Flags =
    { minutes : Int, driver : String, navigator : String }


driverView : String -> Html msg
driverView name =
    p []
        [ iconView "./assets/driver-icon.png"
        , text name
        ]


navigatorView : String -> Html msg
navigatorView name =
    p []
        [ iconView "./assets/navigator-icon.png"
        , text name
        ]


iconView : String -> Html msg
iconView iconUrl =
    img [ style [ ( "max-width", "20px" ) ], src iconUrl ] []


view : Model -> Html msg
view model =
    div [ class "text-center" ]
        [ h1 [] [ text (timerToString (secondsToTimer model.secondsLeft)) ]
        , driverView model.driver
        , navigatorView model.navigator
        ]


updateTimer : Int -> Int
updateTimer seconds =
    seconds - 1


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick time ->
            { model | secondsLeft = (updateTimer model.secondsLeft) } ! []


init : Flags -> ( Model, Cmd msg )
init flags =
    let
        secondsLeft =
            flags.minutes * 60
    in
        ( { secondsLeft = secondsLeft, driver = flags.driver, navigator = flags.navigator }, Cmd.none )


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , subscriptions = \_ -> every second Tick
        , update = update
        , view = view
        }
