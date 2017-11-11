module Github exposing (Info, Release, getReleasesAndStats, starsDecoder)

import Http
import HttpBuilder
import Json.Decode as Decode
import Releases


type alias Info =
    { starCount : Int
    , releases : Releases.PlatformUrls
    }


type alias Release =
    { name : String
    , downloadUrl : String
    }


starsDecoder : Decode.Decoder Info
starsDecoder =
    Decode.map2 Info
        starCountDecoder
        releaseAssetsDecoder


starCountDecoder : Decode.Decoder Int
starCountDecoder =
    Decode.at [ "data", "repository", "stargazers", "totalCount" ]
        Decode.int


releaseAssetsDecoder : Decode.Decoder Releases.PlatformUrls
releaseAssetsDecoder =
    Decode.at
        [ "data", "repository", "releases", "nodes" ]
        (Decode.index 0
            (Decode.at [ "releaseAssets", "edges" ]
                releasesDecoder
            )
        )


releasesDecoder : Decode.Decoder Releases.PlatformUrls
releasesDecoder =
    Decode.list (Decode.field "node" releaseDecoder)
        |> Decode.map Releases.getPlatformReleases


releaseDecoder : Decode.Decoder Release
releaseDecoder =
    Decode.map2 Release
        (Decode.field "name" Decode.string)
        (Decode.field "downloadUrl" Decode.string)


getReleasesAndStats : Http.Request Info
getReleasesAndStats =
    HttpBuilder.post "https://api.github.com/graphql"
        |> HttpBuilder.withHeader "authorization" "Bearer dbd4c239b0bbaa40ab0ea291fa811775da8f5b59"
        |> HttpBuilder.withExpect (Http.expectJson starsDecoder)
        |> HttpBuilder.withStringBody "application/json" """
        {"query":"{\\n  repository(owner: \\"dillonkearns\\", name: \\"mobster\\") {\\n    releases(last: 1) {\\n      totalCount\\n      nodes {\\n        releaseAssets(last: 30) {\\n          edges {\\n            node {\\n              downloadUrl\\n              name\\n              downloadCount\\n            }\\n          }\\n        }\\n        description\\n      }\\n    }\\n    stargazers {\\n      totalCount\\n    }\\n    watchers {\\n      totalCount\\n    }\\n  }\\n}\\n"}
        """
        |> HttpBuilder.toRequest
