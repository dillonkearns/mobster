port module Timer.Main exposing (main)

import Element exposing (Element)
import Element.Attributes
import Html exposing (Html, div, h1, i, img, p, text)
import Html.Attributes exposing (class, src, style)
import Json.Decode as Decode
import Json.Encode as Encode
import Style
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


roleView : String -> String -> Html msg
roleView name iconPath =
    p [] [ iconView iconPath, text name ]


driverIcon : String
driverIcon =
    "../assets/driver-icon.png"


navigatorIcon : String
navigatorIcon =
    "../assets/navigator-icon.png"


iconView : String -> Html msg
iconView iconUrl =
    img [ class "role-icon", style [ ( "max-width", "20px" ) ], src iconUrl ] []


coffeeIcon : Html msg
coffeeIcon =
    div [ style [ ( "font-size", "50px" ) ] ] [ i [ class "text-success fa fa-coffee" ] [] ]


activeMobsters : DriverNavigator -> Html msg
activeMobsters driverNavigator =
    if driverNavigator.driver == "" && driverNavigator.navigator == "" then
        text ""
    else
        div [ style [ ( "margin-top", "8px" ) ] ]
            [ roleView driverNavigator.driver driverIcon
            , roleView driverNavigator.navigator navigatorIcon
            ]


driverNavigatorView : Model -> Html msg
driverNavigatorView model =
    case model.timerType of
        BreakTimer ->
            coffeeIcon

        RegularTimer driverNavigator ->
            activeMobsters driverNavigator


type alias StyleElement =
    Element Styles Never Msg


driverNavigatorViewNew : Model -> StyleElement
driverNavigatorViewNew model =
    case model.timerType of
        BreakTimer ->
            coffeeIcon |> Element.html

        RegularTimer driverNavigator ->
            activeMobstersNew driverNavigator


activeMobstersNew : DriverNavigator -> StyleElement
activeMobstersNew driverNavigator =
    if driverNavigator.driver == "" && driverNavigator.navigator == "" then
        Element.empty
    else
        -- div [ style [ ( "margin-top", "8px" ) ] ]
        --     [ roleViewNew driverNavigator.driver driverIcon
        --     , roleViewNew driverNavigator.navigator navigatorIcon
        --     ]
        Element.column None
            [ Element.Attributes.spacing 12 ]
            [ roleViewNew driverNavigator.driver driverIcon
            , roleViewNew driverNavigator.navigator navigatorIcon
            ]



-- Element.empty


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
    -- img [ class "role-icon", style [ ( "max-width", "20px" ) ], src iconUrl ] []
    Element.image None
        [ Element.Attributes.width (Element.Attributes.px 20)
        , Element.Attributes.height (Element.Attributes.px 20)
        ]
        { src = iconUrl, caption = "icon" }


type Styles
    = None
    | Timer
    | MobsterName


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
        ]


view : Model -> Html Msg
view model =
    new model


new : Model -> Html Msg
new model =
    Element.column None
        []
        [ Element.column Timer
            [ Element.Attributes.paddingXY 8 8
            , Element.Attributes.spacing 8
            , Element.Attributes.center
            ]
            [ Element.text (Timer.timerToString (Timer.secondsToTimer model.secondsLeft))
            , driverNavigatorViewNew model
            ]
        ]
        |> Element.viewport
            styleSheet


old : Model -> Html Msg
old model =
    div [ class "text-center" ]
        [ h1 [ style [ ( "margin", "0px" ), ( "margin-top", "10px" ) ] ]
            [ text (Timer.timerToString (Timer.secondsToTimer model.secondsLeft)) ]
        , driverNavigatorView model
        ]


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
                59 * 60
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
