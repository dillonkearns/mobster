port module Timer.Main exposing (main)

import Color
import Element exposing (Element)
import Element.Attributes
import Html exposing (Html)
import Json.Decode as Decode
import Json.Encode as Encode
import Style
import Style.Color
import Style.Font
import Time
import Timer.Flags exposing (IncomingFlags)
import Timer.Timer as Timer


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


type Msg
    = Tick Time.Time


port timerDone : Int -> Cmd msg


port breakTimerDone : Int -> Cmd msg


driverIcon : String
driverIcon =
    "../assets/driver-icon.png"


navigatorIcon : String
navigatorIcon =
    "../assets/navigator-icon.png"


coffeeIconNew : StyleElement
coffeeIconNew =
    Element.el BreakIcon [ Element.Attributes.class "fa fa-coffee" ] Element.empty


type alias StyleElement =
    Element Styles Never Msg


timerBodyView : Model -> StyleElement
timerBodyView model =
    case model.timerType of
        BreakTimer ->
            coffeeIconNew

        RegularTimer driverNavigator ->
            activeMobstersNew driverNavigator


activeMobstersNew : DriverNavigator -> StyleElement
activeMobstersNew driverNavigator =
    if driverNavigator.driver == "" && driverNavigator.navigator == "" then
        Element.empty
    else
        Element.column None
            [ Element.Attributes.spacing 12
            , Element.Attributes.paddingTop 8
            ]
            [ roleViewNew driverNavigator.driver driverIcon
            , roleViewNew driverNavigator.navigator navigatorIcon
            ]


roleViewNew : String -> String -> StyleElement
roleViewNew name iconPath =
    Element.row MobsterName
        [ Element.Attributes.spacing 4
        , Element.Attributes.center
        ]
        [ iconViewNew iconPath
        , Element.text name
        ]


iconViewNew : String -> StyleElement
iconViewNew iconUrl =
    Element.image None
        [ Element.Attributes.width (Element.Attributes.px 20)
        , Element.Attributes.height (Element.Attributes.px 20)
        ]
        { src = iconUrl, caption = "icon" }


type Styles
    = None
    | Timer
    | MobsterName
    | BreakIcon


styleSheet : Style.StyleSheet Styles Never
styleSheet =
    Style.styleSheet
        [ Style.style None
            [ [ "Lato" ]
                |> List.map Style.Font.font
                |> Style.Font.typeface
            ]
        , Style.style Timer
            [ Style.Font.size 39
            ]
        , Style.style MobsterName
            [ Style.Font.size 15
            ]
        , Style.style BreakIcon
            [ Style.Font.size 50
            , Color.rgb 8 226 108 |> Style.Color.text
            ]
        ]


view : Model -> Html Msg
view model =
    Element.column None
        []
        [ Element.column Timer
            [ Element.Attributes.paddingXY 8 8
            , Element.Attributes.spacing 0
            , Element.Attributes.center
            ]
            [ Element.text (Timer.timerToString (Timer.secondsToTimer model.secondsLeft))
            , timerBodyView model
            ]
        ]
        |> Element.viewport
            styleSheet


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick time ->
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
            breakTimerDone originalDurationSeconds

        RegularTimer _ ->
            timerDone originalDurationSeconds


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
        Time.every Time.second Tick


main : Program Decode.Value Model Msg
main =
    Html.programWithFlags
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
