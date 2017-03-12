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
                in
                    Expect.true (toString rpgData)
                        (List.all (not << .complete) rpgData.driver)
        ]
