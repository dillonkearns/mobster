port module Timer.Main exposing (main, updateTimer)

import Html exposing (..)
import Html.Attributes exposing (class, src, style)
import Json.Decode as Decode
import Json.Encode as Encode
import Time exposing (..)
import Timer.Flags exposing (..)
import Timer.Timer exposing (..)


type TimerType
    = BreakTimer
    | RegularTimer DriverNavigator


type alias DriverNavigator =
    { driver : String, navigator : String }


type alias Model =
    { secondsLeft : Int
    , originalDurationSeconds : Int
    , timerType : TimerType
    }


type Msg
    = Tick Time.Time


port timerDone : Int -> Cmd msg


port breakTimerDone : Int -> Cmd msg


roleView : String -> String -> Html msg
roleView name iconPath =
    p []
        [ iconView navigatorIcon
        , text name
        ]


driverIcon : String
driverIcon =
    "./assets/driver-icon.png"


navigatorIcon : String
navigatorIcon =
    "./assets/navigator-icon.png"


iconView : String -> Html msg
iconView iconUrl =
    img [ class "role-icon", style [ ( "max-width", "20px" ) ], src iconUrl ] []


coffeeIcon : Html msg
coffeeIcon =
    div [ style [ ( "font-size", "50px" ) ] ] [ i [ class "text-success fa fa-coffee" ] [] ]


activeMobsters : DriverNavigator -> Html msg
activeMobsters driverNavigator =
    div [ style [ ( "margin-top", "8px" ) ] ]
        [ roleView driverNavigator.driver driverIcon
        , roleView driverNavigator.navigator navigatorIcon
        ]


mainContent : Model -> Html msg
mainContent model =
    case model.timerType of
        BreakTimer ->
            coffeeIcon

        RegularTimer driverNavigator ->
            activeMobsters driverNavigator


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
            { model | secondsLeft = updatedSecondsLeft }
                ! (if timerComplete updatedSecondsLeft then
                    [ timerDoneCommand model.timerType model.originalDurationSeconds ]
                   else
                    []
                  )


timerDoneCommand : TimerType -> Int -> Cmd msg
timerDoneCommand timerType originalDurationSeconds =
    case timerType of
        BreakTimer ->
            breakTimerDone originalDurationSeconds

        RegularTimer _ ->
            timerDone originalDurationSeconds


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

                timerType =
                    if flags.isBreak then
                        BreakTimer
                    else
                        RegularTimer { driver = flags.driver, navigator = flags.navigator }

                initialModel =
                    { secondsLeft = secondsLeft
                    , originalDurationSeconds = secondsLeft
                    , timerType = timerType
                    }
            in
            ( initialModel, Cmd.none )

        Err _ ->
            Debug.crash "Failed to decode flags"


subscriptions : Model -> Sub Msg
subscriptions model =
    if timerComplete model.secondsLeft then
        Sub.none
    else
        every second Tick


timerComplete : Int -> Bool
timerComplete secondsLeft =
    secondsLeft <= 0


main : Program Decode.Value Model Msg
main =
    Html.programWithFlags
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
