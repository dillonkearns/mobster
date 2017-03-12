module RpgTests exposing (all)

import Test exposing (..)
import Expect
import Mobster.Rpg as Rpg exposing (..)


all : Test
all =
    describe "rpg tests"
        [ test "get new card in a fresh session" <|
            \() ->
                let
                    rpgData =
                        Rpg.init

                    maybeExperience =
                        Rpg.getExperience (L1Role Driver) rpgData
                in
                    case maybeExperience of
                        Just experience ->
                            Expect.true (toString experience)
                                (List.all (not << .complete) experience)

                        Nothing ->
                            Expect.fail "No experience found"
        ]
