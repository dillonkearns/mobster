port module Timer.Main exposing (main)

import Element exposing (Element)
import Element.Attributes
import Html exposing (Html)
import Json.Decode as Decode
import Json.Encode as Encode
import Time
import Timer.Flags exposing (IncomingFlags)
import Timer.Msg as Msg exposing (Msg)
import Timer.Ports
import Timer.Styles as Styles exposing (StyleElement)
import Timer.Timer as Timer
import Timer.View.Icon


type alias Model =
    { secondsLeft : Int
    , originalDurationSeconds : Int
    , timerType : TimerType
    }


type TimerType
    = BreakTimer
    | RegularTimer DriverNavigator


type alias DriverNavigator =
    { driver : String
    , navigator : String
    }


timerBodyView : Model -> StyleElement
timerBodyView model =
    case model.timerType of
        BreakTimer ->
            Timer.View.Icon.coffeeIcon

        RegularTimer driverNavigator ->
            activeMobsters driverNavigator


activeMobsters : DriverNavigator -> StyleElement
activeMobsters driverNavigator =
    if driverNavigator.driver == "" && driverNavigator.navigator == "" then
        Element.empty
    else
        Element.column Styles.None
            [ Element.Attributes.spacing 12
            , Element.Attributes.paddingTop 8
            ]
            [ roleView driverNavigator.driver Timer.View.Icon.driverIcon
            , roleView driverNavigator.navigator Timer.View.Icon.navigatorIcon
            ]


roleView : String -> StyleElement -> StyleElement
roleView name icon =
    Element.row Styles.MobsterName
        [ Element.Attributes.spacing 4
        , Element.Attributes.center
        ]
        [ icon
        , Element.text name
        ]


view : Model -> Html Msg
view model =
    Element.column Styles.None
        []
        [ Element.column Styles.Timer
            [ Element.Attributes.paddingXY 8 8
            , Element.Attributes.spacing 0
            , Element.Attributes.center
            ]
            [ Element.text (Timer.timerToString (Timer.secondsToTimer model.secondsLeft))
            , timerBodyView model
            ]
        ]
        |> Element.viewport
            Styles.styleSheet


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msg.Tick time ->
            let
                updatedSecondsLeft =
                    Timer.updateTimer model.secondsLeft
            in
            { model | secondsLeft = updatedSecondsLeft }
                ! (if Timer.timerComplete updatedSecondsLeft then
                    [ timerDoneCommand model.timerType model.originalDurationSeconds ]
                   else
                    []
                  )


timerDoneCommand : TimerType -> Int -> Cmd msg
timerDoneCommand timerType originalDurationSeconds =
    case timerType of
        BreakTimer ->
            Timer.Ports.breakTimerDone originalDurationSeconds

        RegularTimer _ ->
            Timer.Ports.timerDone originalDurationSeconds


initialModel : IncomingFlags -> Model
initialModel flags =
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
    in
    { secondsLeft = secondsLeft
    , originalDurationSeconds = secondsLeft
    , timerType = timerType
    }


init : Encode.Value -> ( Model, Cmd msg )
init flagsJson =
    case Decode.decodeValue Timer.Flags.decoder flagsJson of
        Ok flags ->
            initialModel flags ! []

        Err _ ->
            Debug.crash "Failed to decode flags"


subscriptions : Model -> Sub Msg
subscriptions model =
    if Timer.timerComplete model.secondsLeft then
        Sub.none
    else
        Time.every Time.second Msg.Tick


main : Program Decode.Value Model Msg
main =
    Html.programWithFlags
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
