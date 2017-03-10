module MobsterOperationTests exposing (all)

import Test exposing (..)
import Expect
import Mobster exposing (MobsterData, empty)
import MobsterOperation exposing (MobsterOperation(..), updateMoblist)


all : Test
all =
    describe "mobster operation" [ benchCases, removeCases, rotateCases ]


benchCases : Test
benchCases =
    describe "bench"
        [ mobsterOperationTest "list with single item"
            { empty | mobsters = [ "only item" ] }
            (Bench 0)
            { empty | inactiveMobsters = [ "only item" ], nextDriver = 0 }
        , mobsterOperationTest "with multiple items"
            { empty | mobsters = [ "first", "second" ] }
            (Bench 0)
            { empty | mobsters = [ "second" ], inactiveMobsters = [ "first" ], nextDriver = 0 }
        , mobsterOperationTest "driver doesn't change when navigator is removed"
            { empty | mobsters = [ "Kirk", "Spock", "McCoy" ] }
            (Bench 1)
            { empty | mobsters = [ "Kirk", "McCoy" ], inactiveMobsters = [ "Spock" ], nextDriver = 0 }
        , mobsterOperationTest "wraps around list for next driver when nextDriver is removed and was at end of list"
            { empty | mobsters = [ "Kirk", "Spock", "McCoy" ], nextDriver = 2 }
            (Bench 2)
            { empty | mobsters = [ "Kirk", "Spock" ], inactiveMobsters = [ "McCoy" ], nextDriver = 0 }
        ]


removeCases : Test
removeCases =
    describe "remove"
        [ mobsterOperationTest "removes an item from bench with no active mobsters"
            { empty | inactiveMobsters = [ "Kirk", "Spock", "McCoy" ] }
            (Remove 1)
            { empty | inactiveMobsters = [ "Kirk", "McCoy" ] }
        ]


rotateCase1 : Test
rotateCase1 =
    let
        startList =
            { empty | mobsters = [ "Jane Doe", "John Smith" ], nextDriver = 0 }
    in
        mobsterOperationTest "without wrapping"
            startList
            NextTurn
            { startList | nextDriver = 1 }


rotateCase2 : Test
rotateCase2 =
    let
        startList =
            { empty | mobsters = [ "Jane Doe", "John Smith" ], nextDriver = 1 }
    in
        mobsterOperationTest "with wrapping"
            startList
            NextTurn
            { startList | nextDriver = 0 }


rotateCases : Test
rotateCases =
    describe "rotate" [ rotateCase1, rotateCase2 ]


mobsterOperationTest : String -> MobsterData -> MobsterOperation -> MobsterData -> Test
mobsterOperationTest description startList operation expectedResult =
    test description <|
        \() ->
            startList
                |> updateMoblist operation
                |> Expect.equal expectedResult
