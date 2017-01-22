port module Setup.Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, value, type_, id)
import Html.Events exposing (on, keyCode, onClick, onInput, onSubmit)
import Json.Decode as Json


onEnter : Msg -> Attribute Msg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                Json.succeed msg
            else
                Json.fail "not the right keycode"
    in
        on "keydown" (keyCode |> Json.andThen isEnter)


type Msg
    = StartTimer
    | UpdateMobsterInput String
    | AddMobster
    | ChangeTimerDuration String
    | SelectDurationInput
    | OpenConfigure
    | Quit


type ScreenState
    = Configure
    | Continue


type alias Mobster =
    String


type alias MobsterList =
    List Mobster


emptyMobsterList : MobsterList
emptyMobsterList =
    []



-- , current : Int }


type alias Model =
    { timerDuration : Int
    , screenState : ScreenState
    , mobsterList : MobsterList
    , newMobster : Mobster
    }


initialModel : Model
initialModel =
    { timerDuration = 5
    , screenState = Configure
    , mobsterList = emptyMobsterList
    , newMobster = ""
    }


type alias TimerConfiguration =
    { minutes : Int, driver : String, navigator : String }


flags : Model -> TimerConfiguration
flags model =
    { minutes = model.timerDuration, driver = "Hello", navigator = "World" }


port starttimer : TimerConfiguration -> Cmd msg


port quit : String -> Cmd msg


port selectduration : String -> Cmd msg


timerDurationInputView : Int -> Html Msg
timerDurationInputView duration =
    div [ class "text-primary h1" ]
        [ input
            [ id "timer-duration"
            , onClick SelectDurationInput
            , onInput ChangeTimerDuration
            , type_ "number"
            , Html.Attributes.min "1"
            , Html.Attributes.max "15"
            , value (toString duration)
            ]
            []
        , text "Minutes"
        ]


quitButton : Html Msg
quitButton =
    div []
        [ button [ onClick Quit, class "btn btn-primary btn-md" ] [ text "Quit" ]
        ]


configureView : Model -> Html Msg
configureView model =
    div []
        [ h1 [ class "text-primary text-center" ] [ text "Mobster" ]
        , div [ class "text-center" ]
            [ button [ onClick StartTimer, class "btn btn-primary btn-lg" ] [ text "Start Mobbing" ]
            , timerDurationInputView model.timerDuration
            , mobstersView model.newMobster model.mobsterList
            , quitButton
            ]
        ]


continueView : Model -> Html Msg
continueView model =
    h1 [ class "text-primary text-center" ]
        [ text "Mobster"
        , div [ class "text-center" ]
            [ button [ onClick StartTimer, class "btn btn-primary btn-lg" ] [ text "Continue" ]
            , div [] [ button [ onClick OpenConfigure, class "btn btn-primary btn-md" ] [ text "Configure" ] ]
            , quitButton
            ]
        ]


mobstersView : Mobster -> MobsterList -> Html Msg
mobstersView newMobster mobsterList =
    div []
        [ ul [] (List.map (\mobsterName -> li [] [ text mobsterName ]) mobsterList)
        , div []
            [ input [ type_ "text", value newMobster, onInput UpdateMobsterInput, onEnter AddMobster ] []
            ]
        , button [ class "btn btn-primary", onClick AddMobster ] [ text "Add Mobster" ]
        ]


view : Model -> Html Msg
view model =
    case model.screenState of
        Configure ->
            configureView model

        Continue ->
            continueView model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        StartTimer ->
            { model | screenState = Continue }
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
                { model | timerDuration = duration } ! []

        SelectDurationInput ->
            model ! [ selectduration "timer-duration" ]

        OpenConfigure ->
            { model | screenState = Configure } ! []

        AddMobster ->
            if model.newMobster == "" then
                model ! []
            else
                (addMobster model.newMobster model) ! []

        UpdateMobsterInput text ->
            { model | newMobster = text } ! []

        Quit ->
            model ! [ quit "" ]


addMobster : Mobster -> Model -> Model
addMobster newMobster model =
    let
        updatedMobsterList =
            model.newMobster :: model.mobsterList
    in
        { model | newMobster = "", mobsterList = updatedMobsterList }


main : Program Never Model Msg
main =
    Html.program
        { init = ( initialModel, Cmd.none )
        , subscriptions = \_ -> Sub.none
        , update = update
        , view = view
        }
