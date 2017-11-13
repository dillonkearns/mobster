port module Main exposing (main)

import Analytics exposing (Event)
import Element exposing (..)
import Element.Attributes exposing (..)
import Github
import Html
import Msg exposing (Msg)
import Os exposing (Os)
import RemoteData exposing (WebData)
import Styles exposing (..)
import Task
import Views.DownloadButton as DownloadButton
import Views.Navbar as Navbar
import Window


type alias Flags =
    { os : String }


(=>) : a -> b -> ( a, b )
(=>) =
    (,)


type alias Model =
    { device : Device
    , githubInfo : WebData Github.Info
    , os : Os
    }


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        _ =
            Debug.log "flags" flags
    in
    ( { device = Element.classifyDevice (Window.Size 0 0)
      , githubInfo = RemoteData.Loading
      , os = Os.fromString flags.os
      }
    , Cmd.batch
        [ getInitialWindowSize
        , Github.getReleasesAndStats |> RemoteData.sendRequest |> Cmd.map Msg.GotGithubInfo
        ]
    )


getInitialWindowSize : Cmd Msg
getInitialWindowSize =
    Window.size |> Task.perform Msg.WindowResized


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msg.WindowResized windowSize ->
            { model | device = Element.classifyDevice windowSize } ! []

        Msg.GotGithubInfo githubInfo ->
            ( { model | githubInfo = githubInfo }, Cmd.none )

        Msg.TrackDownloadClick os ->
            ( model
            , trackEvent
                { name = "download"
                , category = "engagement"
                , label = toString os
                }
            )


subscriptions : a -> Sub Msg
subscriptions model =
    Window.resizes Msg.WindowResized


mainContent : { model | githubInfo : WebData Github.Info, os : Os, device : Device } -> StyleElement
mainContent model =
    column TopLevel
        [ height fill ]
        [ (if model.device.phone then
            column
           else
            row
          )
            Main
            [ padding 50
            , center
            , spacing 50
            ]
            [ DownloadButton.view model
            , tagline
            ]
        , column TopLevel
            [ padding 50
            , center
            , spacing 50
            ]
            [ text "Get a friendly reminder to pass the keyboard"
                |> el SubHeading []
            , Element.image None
                [ if model.device.phone then
                    width (percent 95)
                  else
                    width (percent 80)
                , verticalCenter
                ]
                { src = "./assets/screenshot1.png", caption = "icon" }
            ]
        ]


tagline : StyleElement
tagline =
    column None
        [ center ]
        [ text "Pair and Mob Program"
            |> el TaglineA []
        , text "With Ease"
            |> el TaglineB []
        ]


releasesUrl : String
releasesUrl =
    "https://github.com/dillonkearns/mobster/releases"


view : Model -> Html.Html Msg
view model =
    Element.viewport (Styles.stylesheet model.device) <|
        column TopLevel
            [ height fill ]
            [ Navbar.view model
            , mainContent model
            ]


port trackEvent : Event -> Cmd msg
