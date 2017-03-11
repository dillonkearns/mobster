module MobsterDataTests exposing (all)

import Test exposing (..)
import Expect
import Mobster.Data as Mobster exposing (empty)


all : Test
all =
    describe "mobster data"
        [ describe "containsName"
            [ test "catches exact matches" <|
                \() ->
                    { empty | mobsters = [ "Jane" ] }
                        |> Mobster.containsName "Jane"
                        |> Expect.equal True
            , test "catches matches with different casing" <|
                \() ->
                    { empty | mobsters = [ "jane" ] }
                        |> Mobster.containsName "Jane"
                        |> Expect.equal True
            , test "finds matches on bench" <|
                \() ->
                    { empty | inactiveMobsters = [ "Jane" ] }
                        |> Mobster.containsName "Jane"
                        |> Expect.equal True
            , test "doesn't find false matches" <|
                \() ->
                    { empty | inactiveMobsters = [ "Joe" ] }
                        |> Mobster.containsName "Jane"
                        |> Expect.equal False
            ]
        ]
