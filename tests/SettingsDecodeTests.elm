module SettingsDecodeTests exposing (all)

import Test exposing (..)
import Test.Extra exposing (..)
import Mobster
import Setup.Settings


all : Test
all =
    describe "decoders"
        [ describeDecoder "MobsterData"
            Mobster.decoder
            [ ( "", FailsToDecode )
            , ( """{
                     "mobsters": [],
                     "inactiveMobsters": [],
                     "nextDriver": 0
                   }""", DecodesTo Mobster.empty )
            ]
        , describeDecoder "Settings"
            Setup.Settings.decoder
            [ ( """{
                      "mobsterData": {
                        "mobsters": [],
                        "inactiveMobsters": [],
                        "nextDriver": 0
                      },
                      "timerDuration": 5,
                      "intervalsPerBreak": 6
                    }""", DecodesTo (Setup.Settings.Data 5 6 Mobster.empty) )
            ]
        ]
