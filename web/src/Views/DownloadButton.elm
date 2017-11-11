module Views.DownloadButton exposing (view)

import Element exposing (..)
import Element.Attributes exposing (..)
import Github
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
            downloadButtonForOs .mac "fa-apple" githubInfo

        Os.Windows ->
            downloadButtonForOs .windows "fa-windows" githubInfo

        Os.Linux ->
            downloadButtonForOs .linux "fa-linux" githubInfo

        Os.Other ->
            downloadButtonView releasesUrl [ text "Download" ]


downloadButtonForOs : (Releases.PlatformUrls -> String) -> String -> WebData Github.Info -> StyleElement
downloadButtonForOs getPlatformDownloadUrl platformIcon githubInfo =
    column Styles.None
        [ spacing 10 ]
        [ downloadButtonView
            (githubInfo
                |> RemoteData.map (\info -> info.releases)
                |> RemoteData.map getPlatformDownloadUrl
                |> RemoteData.withDefault releasesUrl
            )
            [ text "Download", Fa.fa Styles.None platformIcon ]
        , otherPlatformsLink
        ]


downloadButtonView :
    String
    -> List StyleElement
    -> StyleElement
downloadButtonView href buttonContents =
    row Styles.DownloadButton
        [ padding 20
        , center
        , spacing 10
        , attribute "href" href
        ]
        buttonContents
        |> node "a"


releasesUrl : String
releasesUrl =
    "https://github.com/dillonkearns/mobster/releases"
