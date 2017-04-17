port module Timer.Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, src, style)
import Time exposing (..)
import Timer.Flags exposing (IncomingFlags)
import Timer.Timer exposing (..)
import Json.Encode as Encode
import Json.Decode as Decode


type alias Model =
    { driver : String, navigator : String, secondsLeft : Int, originalDurationSeconds : Int, isBreak : Bool }


type Msg
    = Tick Time.Time


port timerDone : Int -> Cmd msg


port breakTimerDone : Int -> Cmd msg


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


coffeeIcon : Html msg
coffeeIcon =
    div [ style [ ( "font-size", "50px" ) ] ] [ i [ class "text-success fa fa-coffee" ] [] ]


activeMobsters : Model -> Html msg
activeMobsters model =
    div [ style [ ( "margin-top", "8px" ) ] ]
        [ driverView model.driver
        , navigatorView model.navigator
        ]


mainContent : Model -> Html msg
mainContent model =
    if model.isBreak then
        coffeeIcon
    else
        activeMobsters model


view : Model -> Html msg
view model =
    div [ class "text-center" ]
        [ h1 [ style [ ( "margin", "0px" ), ( "margin-top", "10px" ) ] ]
            [ text (timerToString (secondsToTimer model.secondsLeft)) ]
        , mainContent model
        ]


updateTimer : Int -> Int
updateTimer seconds =
    seconds - 1


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick time ->
            let
                updatedSecondsLeft =
                    updateTimer model.secondsLeft
            in
                if updatedSecondsLeft <= 0 then
                    if model.isBreak then
                        model ! [ breakTimerDone model.originalDurationSeconds ]
                    else
                        model ! [ timerDone model.originalDurationSeconds ]
                else
                    { model | secondsLeft = updatedSecondsLeft } ! []


init : Encode.Value -> ( Model, Cmd msg )
init flagsJson =
    case Decode.decodeValue Timer.Flags.decoder flagsJson of
        Ok flags ->
            let
                secondsLeft =
                    if flags.isDev then
                        -- just show timer for one second no matter what it's set to
                        1
                    else
                        flags.minutes * 60
            in
                ( { secondsLeft = secondsLeft, driver = flags.driver, navigator = flags.navigator, originalDurationSeconds = secondsLeft, isBreak = flags.isBreak }, Cmd.none )

        Err _ ->
            Debug.crash "Failed to decode flags"


type alias Flags =
    { timerFlags : Timer.Flags.Flags, isDev : Bool }


main : Program Decode.Value Model Msg
main =
    Html.programWithFlags
        { init = init
        , subscriptions = \_ -> every second Tick
        , update = update
        , view = view
        }
