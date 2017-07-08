module MobsterDataTests exposing (suite)

import Expect
import Roster.Data exposing (empty)
import Test exposing (..)
import Test.Extra exposing (..)
import TestHelpers exposing (toMobsters)


suite : Test
suite =
    describe "mobster data"
        [ describe "containsName"
            [ test "catches exact matches" <|
                \() ->
                    { empty | mobsters = [ "Jane" ] |> toMobsters }
                        |> Roster.Data.containsName "Jane"
                        |> Expect.equal True
            , test "catches matches with different casing" <|
                \() ->
                    { empty | mobsters = [ "jane" ] |> toMobsters }
                        |> Roster.Data.containsName "Jane"
                        |> Expect.equal True
            , test "finds matches on bench" <|
                \() ->
                    { empty | inactiveMobsters = [ "Jane" ] |> toMobsters }
                        |> Roster.Data.containsName "Jane"
                        |> Expect.equal True
            , test "doesn't find false matches" <|
                \() ->
                    { empty | inactiveMobsters = [ "Joe" ] |> toMobsters }
                        |> Roster.Data.containsName "Jane"
                        |> Expect.equal False
            ]
        , describeDecoder "RosterData"
            Roster.Data.decoder
            [ ( "", FailsToDecode )
            , ( """{
                     "mobsters": [],
                     "inactiveMobsters": [],
                     "nextDriver": 0
                   }""", DecodesTo Roster.Data.empty )
            ]
        ]
