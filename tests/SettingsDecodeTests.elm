module SettingsDecodeTests exposing (fuzzTests, suite)

import Expect
import Fuzz exposing (Fuzzer)
import Json.Decode as Decode
import Roster.Data exposing (empty)
import Setup.Settings
import Test exposing (..)
import Test.Extra exposing (..)
import TestHelpers exposing (toMobsters)


suite : Test
suite =
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
                      "breakDuration": 5,
                      "intervalsPerBreak": 6,
                      "showHideShortcut": "foo"
                    }"""
              , DecodesTo <| Just <| Setup.Settings.Data 5 5 6 Roster.Data.empty "foo"
              )
            , ( "null", DecodesTo Nothing )
            ]
        , describeDecoder "RosterData"
            Setup.Settings.decoder
            [ ( """{
                      "mobsterData": {
                        "mobsters": ["Uhura", "Sulu"],
                        "inactiveMobsters": ["Kirk", "Spock"],
                        "nextDriver": 0
                      },
                      "timerDuration": 5,
                      "breakDuration": 5,
                      "intervalsPerBreak": 6,
                      "showHideShortcut": "foo"
                    }""", DecodesTo <| Just <| Setup.Settings.Data 5 5 6 { empty | mobsters = [ "Uhura", "Sulu" ] |> toMobsters, inactiveMobsters = [ "Kirk", "Spock" ] |> toMobsters } "foo" )
            ]
        , test "decoder is able to parse fields generated in encoder" <|
            \() ->
                Setup.Settings.Data 5 5 6 { empty | mobsters = [ "Uhura", "Sulu" ] |> toMobsters, inactiveMobsters = [ "Kirk", "Spock" ] |> toMobsters } "foo"
                    |> Setup.Settings.encoder
                    |> Decode.decodeValue Setup.Settings.decoder
                    |> Expect.equal
                        (Ok <| Just (Setup.Settings.Data 5 5 6 { empty | mobsters = [ "Uhura", "Sulu" ] |> toMobsters, inactiveMobsters = [ "Kirk", "Spock" ] |> toMobsters } "foo"))
        ]


settingsFuzzer : Fuzzer Setup.Settings.Data
settingsFuzzer =
    Fuzz.map5 Setup.Settings.Data Fuzz.int Fuzz.int Fuzz.int rosterFuzzer (Fuzz.char |> Fuzz.map toString)


rosterFuzzer : Fuzzer Roster.Data.RosterData
rosterFuzzer =
    Fuzz.map3 Roster.Data.RosterData (Fuzz.list (Fuzz.string |> Fuzz.map Roster.Data.createMobster)) (Fuzz.list (Fuzz.string |> Fuzz.map Roster.Data.createMobster)) (Fuzz.constant 0)


fuzzTests : Test
fuzzTests =
    Test.fuzz settingsFuzzer "settings fuzz test" <|
        \settings ->
            settings
                |> Setup.Settings.encoder
                |> Decode.decodeValue Setup.Settings.decoder
                |> Expect.equal (settings |> Just |> Ok)
