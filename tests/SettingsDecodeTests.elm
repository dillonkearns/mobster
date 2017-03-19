module SettingsDecodeTests exposing (all)

import Test exposing (..)
import Test.Extra exposing (..)
import Mobster.Data exposing (empty)
import Setup.Settings
import TestHelpers exposing (toMobsters)


all : Test
all =
    describe "decoders"
        [ describeDecoder "Settings"
            Setup.Settings.decoder
            [ ( """{
                      "mobsterData": {
                        "mobsters": [],
                        "inactiveMobsters": [],
                        "nextDriver": 0
                      },
                      "timerDuration": 5,
                      "intervalsPerBreak": 6
                    }""", DecodesTo (Setup.Settings.Data 5 6 Mobster.Data.empty) )
            ]
        , describeDecoder "MobsterData"
            Setup.Settings.decoder
            [ ( """{
                      "mobsterData": {
                        "mobsters": ["Uhura", "Sulu"],
                        "inactiveMobsters": ["Kirk", "Spock"],
                        "nextDriver": 0
                      },
                      "timerDuration": 5,
                      "intervalsPerBreak": 6
                    }""", DecodesTo (Setup.Settings.Data 5 6 { empty | mobsters = [ "Uhura", "Sulu" ] |> toMobsters, inactiveMobsters = [ "Kirk", "Spock" ] |> toMobsters }) )
            ]
        ]
