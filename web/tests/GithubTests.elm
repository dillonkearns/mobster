module GithubTests exposing (suite)

import Github
import Test exposing (..)
import Test.Extra exposing (DecoderExpectation(DecodesTo))


(=>) : a -> b -> ( a, b )
(=>) =
    (,)


suite : Test
suite =
    Test.Extra.describeDecoder "github decoder"
        Github.starsDecoder
        [ ( """
        {
          "data": {
            "repository": {
              "releases": {
                "totalCount": 47,
                "nodes": [
                  {
                    "releaseAssets": {
                      "edges": [
                        {
                          "node": {
                            "downloadUrl":
                              "https://github.com/dillonkearns/mobster/releases/download/v0.0.47/Mobster-0.0.47-mac.zip",
                            "name": "Mobster-0.0.47-mac.zip"
                          }
                        },
                        {
                          "node": {
                            "downloadUrl":
                              "https://github.com/dillonkearns/mobster/releases/download/v0.0.47/latest-mac.json",
                            "name": "latest-mac.json"
                          }
                        },
                        {
                          "node": {
                            "downloadUrl":
                              "https://github.com/dillonkearns/mobster/releases/download/v0.0.47/Mobster-0.0.47.dmg",
                            "name": "Mobster-0.0.47.dmg"
                          }
                        },
                        {
                          "node": {
                            "downloadUrl":
                              "https://github.com/dillonkearns/mobster/releases/download/v0.0.47/Mobster-0.0.47-x86_64.AppImage",
                            "name": "Mobster-0.0.47-x86_64.AppImage"
                          }
                        },
                        {
                          "node": {
                            "downloadUrl":
                              "https://github.com/dillonkearns/mobster/releases/download/v0.0.47/Mobster-Setup-0.0.47.exe",
                            "name": "Mobster-Setup-0.0.47.exe"
                          }
                        },
                        {
                          "node": {
                            "downloadUrl":
                              "https://github.com/dillonkearns/mobster/releases/download/v0.0.47/latest.yml",
                            "name": "latest.yml"
                          }
                        }
                      ]
                    },
                    "description":
                      "- Make shuffle die box clickable\\r\\n- Fix issue with break auto reset interval (will reset after 20 minutes of inactivity, not 2)"
                  }
                ]
              },
              "stargazers": { "totalCount": 68 }
            }
          }
        }
        """
          , DecodesTo
                { starCount = 68
                , releases =
                    { mac = "https://github.com/dillonkearns/mobster/releases/download/v0.0.47/Mobster-0.0.47-mac.zip"
                    , windows = "https://github.com/dillonkearns/mobster/releases/download/v0.0.47/Mobster-Setup-0.0.47.exe"
                    , linux = "https://github.com/dillonkearns/mobster/releases/download/v0.0.47/Mobster-0.0.47-x86_64.AppImage"
                    }
                }
          )
        ]
