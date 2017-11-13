module Views.DownloadButton exposing (view)

import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (onClick)
import Github
import Msg
import Os exposing (Os)
import Releases
import RemoteData exposing (WebData)
import Styles exposing (StyleElement, Styles)
import Views.Fa as Fa


otherPlatformsLink : StyleElement
otherPlatformsLink =
    text "Other platforms"
        |> el Styles.OtherPlatformsLink []
        |> link releasesUrl


view : { model | githubInfo : WebData Github.Info, os : Os } -> StyleElement
view { githubInfo, os } =
    case os of
        Os.Mac ->
            downloadButtonForOs .mac "fa-apple" os githubInfo

        Os.Windows ->
            downloadButtonForOs .windows "fa-windows" os githubInfo

        Os.Linux ->
            downloadButtonForOs .linux "fa-linux" os githubInfo

        Os.Other ->
            downloadButtonView releasesUrl
                os
                [ text "Download"
                , Fa.fa Styles.None "fa-apple"
                , Fa.fa Styles.None "fa-windows"
                , Fa.fa Styles.None "fa-linux"
                ]


downloadButtonForOs : (Releases.PlatformUrls -> String) -> String -> Os -> WebData Github.Info -> StyleElement
downloadButtonForOs getPlatformDownloadUrl platformIcon os githubInfo =
    column Styles.None
        [ spacing 10 ]
        [ downloadButtonView
            (githubInfo
                |> RemoteData.map (\info -> info.releases)
                |> RemoteData.map getPlatformDownloadUrl
                |> RemoteData.withDefault releasesUrl
            )
            os
            [ text "Download", Fa.fa Styles.None platformIcon ]
        , otherPlatformsLink
        ]


downloadButtonView :
    String
    -> Os
    -> List StyleElement
    -> StyleElement
downloadButtonView href os buttonContents =
    row Styles.DownloadButton
        [ padding 20
        , center
        , spacing 10
        , attribute "href" href
        , attribute "target" "_blank"
        , onClick (Msg.TrackDownloadClick os)
        ]
        buttonContents
        |> node "a"


releasesUrl : String
releasesUrl =
    "https://github.com/dillonkearns/mobster/releases"
