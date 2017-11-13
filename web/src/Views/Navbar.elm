module Views.Navbar exposing (view)

import Element exposing (..)
import Element.Attributes exposing (..)
import Github
import RemoteData exposing (WebData)
import Styles exposing (..)
import Views.Fa as Fa
import Views.GithubStar


view : { model | githubInfo : WebData Github.Info, device : Device } -> StyleElement
view ({ device } as model) =
    row Navbar
        [ spread
        , if device.width < 800 then
            paddingXY 10 18
          else
            paddingXY 150 18
        , verticalCenter
        ]
        [ navbarTitle
        , navbarLinks model
        ]


navbarTitle : StyleElement
navbarTitle =
    row Title
        [ spacing 20 ]
        [ Views.GithubStar.logo |> el Title [ width (px 65), verticalCenter ]
        , text "Mobster"
        ]


navbarLinks : { model | githubInfo : WebData Github.Info } -> StyleElement
navbarLinks model =
    row NavbarLinks
        [ spacing 12, verticalCenter ]
        [ Fa.fa NavbarLink "fa-github" |> linkify "https://github.com/dillonkearns/mobster"
        , starCount model
        ]


linkify : String -> StyleElement -> StyleElement
linkify href element =
    element |> el None [ attribute "href" href, attribute "target" "_blank" ] |> node "a"


starCount : { model | githubInfo : WebData Github.Info } -> StyleElement
starCount { githubInfo } =
    case githubInfo of
        RemoteData.Success { starCount } ->
            [ Views.GithubStar.view, text (toString starCount) ]
                |> row StarCount [ paddingXY 8 0, verticalCenter ]

        _ ->
            empty
