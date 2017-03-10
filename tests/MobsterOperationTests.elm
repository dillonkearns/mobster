module MobsterOperationTests exposing (all)

import Test exposing (..)
import Expect
import Mobster exposing (MobsterData, empty)
import MobsterOperation exposing (MobsterOperation(..), updateMoblist)


all : Test
all =
    describe "mobster operation" [ benchCases, benchCases2, removeCases, rotateCases, moveCases ]


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


benchCases2 : Test
benchCases2 =
    describe "move"
        [ describe "move to inactive"
            [ mobsterOperationTest "moves a single mobster to an empty bench"
                { empty | mobsters = [ "Spock" ] }
                (Bench 0)
                { empty | inactiveMobsters = [ "Spock" ] }
            , test "puts mobsters on bench in order they are added" <|
                \() ->
                    { empty | mobsters = [ "Kirk", "Spock", "McCoy" ] }
                        |> updateMoblist (Bench 1)
                        |> updateMoblist (Bench 1)
                        |> Expect.equal { empty | mobsters = [ "Kirk" ], inactiveMobsters = [ "Spock", "McCoy" ] }
            ]
        , describe "active"
            [ mobsterOperationTest "puts mobster back in rotation"
                { empty | inactiveMobsters = [ "Kirk", "Spock", "McCoy" ] }
                (RotateIn 2)
                { empty | inactiveMobsters = [ "Kirk", "Spock" ], mobsters = [ "McCoy" ] }
            , mobsterOperationTest "adds mobsters back in rotation below the next driver"
                { empty | mobsters = [ "Kirk", "Spock", "McCoy" ], inactiveMobsters = [ "Sulu" ], nextDriver = 1 }
                (RotateIn 0)
                { empty | mobsters = [ "Kirk", "Spock", "Sulu", "McCoy" ], nextDriver = 1 }
            ]
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


moveCases : Test
moveCases =
    describe "move"
        [ mobsterOperationTest "single item list"
            { empty | mobsters = [ "only item" ], nextDriver = 0 }
            (Move 0 0)
            { empty | mobsters = [ "only item" ], nextDriver = 0 }
        , mobsterOperationTest "index not in list"
            { empty | mobsters = [ "a", "b", "d", "c" ], nextDriver = 0 }
            (Move 4 3)
            { empty | mobsters = [ "a", "b", "d", "c" ], nextDriver = 0 }
        , mobsterOperationTest "multiple items without wrapping"
            { empty | mobsters = [ "a", "b", "d", "c" ], nextDriver = 0 }
            (Move 3 2)
            { empty | mobsters = [ "a", "b", "c", "d" ], nextDriver = 0 }
        , mobsterOperationTest "placing it below hovered slot when moving from higher to lower"
            { empty | mobsters = [ "a", "b", "c" ], nextDriver = 0 }
            (Move 0 1)
            { empty | mobsters = [ "b", "a", "c" ], nextDriver = 0 }
        , mobsterOperationTest "to specific position one up"
            { empty | mobsters = [ "a", "b", "c", "d" ], nextDriver = 0 }
            (Move 3 2)
            { empty | mobsters = [ "a", "b", "d", "c" ], nextDriver = 0 }
        , mobsterOperationTest "to specific position two up"
            { empty | mobsters = [ "a", "b", "c", "d" ], nextDriver = 0 }
            (Move 3 1)
            { empty | mobsters = [ "a", "d", "b", "c" ], nextDriver = 0 }
        , mobsterOperationTest "down below the last item in list"
            { empty | mobsters = [ "a", "b", "c", "d" ], nextDriver = 0 }
            (Move 0 3)
            { empty | mobsters = [ "b", "c", "d", "a" ], nextDriver = 0 }
        , mobsterOperationTest "to specific position several slots away"
            { empty | mobsters = [ "a", "b", "c", "d", "e", "f", "g" ], nextDriver = 0 }
            (Move 6 0)
            { empty | mobsters = [ "g", "a", "b", "c", "d", "e", "f" ], nextDriver = 0 }
        ]


mobsterOperationTest : String -> MobsterData -> MobsterOperation -> MobsterData -> Test
mobsterOperationTest description startList operation expectedResult =
    test description <|
        \() ->
            startList
                |> updateMoblist operation
                |> Expect.equal expectedResult
