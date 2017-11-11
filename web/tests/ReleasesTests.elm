module ReleasesTests exposing (suite)

import Expect
import Releases exposing (PlatformUrls, Release)
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "releases"
        [ test "converts to data structure" <|
            \() ->
                Releases.getPlatformReleases
                    [ { name = "Mobster-0.0.47-mac.zip", downloadUrl = "macUrl" }
                    , { name = "latest-mac.json", downloadUrl = "https://github.com/dillonkearns/mobster/releases/download/v0.0.47/latest-mac.json" }
                    , { name = "Mobster-0.0.47.dmg", downloadUrl = "https://github.com/dillonkearns/mobster/releases/download/v0.0.47/Mobster-0.0.47.dmg" }
                    , { name = "Mobster-0.0.47-x86_64.AppImage", downloadUrl = "linuxUrl" }
                    , { name = "Mobster-Setup-0.0.47.exe", downloadUrl = "windowsUrl" }
                    , { name = "latest.yml", downloadUrl = "https://github.com/dillonkearns/mobster/releases/download/v0.0.47/latest.yml" }
                    ]
                    |> Expect.equal
                        { mac = "macUrl"
                        , windows = "windowsUrl"
                        , linux = "linuxUrl"
                        }
        ]
