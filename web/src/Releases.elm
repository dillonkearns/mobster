module Releases exposing (PlatformUrls, Release, getPlatformReleases)


type alias Release =
    { name : String
    , downloadUrl : String
    }


type alias PlatformUrls =
    { mac : String, windows : String, linux : String }


getPlatformReleases : List Release -> PlatformUrls
getPlatformReleases releases =
    { mac = findAsset "mac.zip" releases
    , windows = findAsset ".exe" releases
    , linux = findAsset ".AppImage" releases
    }


findAsset : String -> List Release -> String
findAsset suffix releases =
    releases
        |> List.filter (\{ name } -> String.endsWith suffix name)
        |> List.head
        |> Maybe.map .downloadUrl
        |> Maybe.withDefault ""
