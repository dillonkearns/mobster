module MobsterOperationTests exposing (all)

import Test exposing (..)
import Expect
import Mobster.Data as Mobster exposing (MobsterData, empty)
import Mobster.Operation exposing (MobsterOperation(..), updateMoblist)


all : Test
all =
    describe "mobster operation" [ benchCases, rotateInCases, removeCases, rotateCases, moveCases, addCases ]


benchCases : Test
benchCases =
    describe "bench"
        [ testOperation "driver doesn't change when navigator is removed"
            { empty | mobsters = [ "Kirk", "Spock", "McCoy" ] }
            (Bench 1)
            { empty | mobsters = [ "Kirk", "McCoy" ], inactiveMobsters = [ "Spock" ], nextDriver = 0 }
        , testOperation "wraps around list for next driver when nextDriver is removed and was at end of list"
            { empty | mobsters = [ "Kirk", "Spock", "McCoy" ], nextDriver = 2 }
            (Bench 2)
            { empty | mobsters = [ "Kirk", "Spock" ], inactiveMobsters = [ "McCoy" ], nextDriver = 0 }
        , testOperation "moves a single mobster to an empty bench"
            { empty | mobsters = [ "Spock" ] }
            (Bench 0)
            { empty | inactiveMobsters = [ "Spock" ] }
        , testOperation "moves the mobster with the correct index"
            { empty | mobsters = [ "Spock", "Sulu" ] }
            (Bench 0)
            { empty | mobsters = [ "Sulu" ], inactiveMobsters = [ "Spock" ] }
        , testOperations "puts mobsters on bench in order they are added"
            { empty | mobsters = [ "Kirk", "Spock", "McCoy" ] }
            [ (Bench 1), (Bench 1) ]
            { empty | mobsters = [ "Kirk" ], inactiveMobsters = [ "Spock", "McCoy" ] }
        ]


rotateInCases : Test
rotateInCases =
    describe "rotate in"
        [ testOperation "puts mobster back in rotation"
            { empty | inactiveMobsters = [ "Kirk", "Spock", "McCoy" ] }
            (RotateIn 2)
            { empty | inactiveMobsters = [ "Kirk", "Spock" ], mobsters = [ "McCoy" ] }
        , testOperation "adds mobsters back in rotation below the next driver"
            { empty | mobsters = [ "Kirk", "Spock", "McCoy" ], inactiveMobsters = [ "Sulu" ], nextDriver = 1 }
            (RotateIn 0)
            { empty | mobsters = [ "Kirk", "Spock", "Sulu", "McCoy" ], nextDriver = 1 }
        ]


removeCases : Test
removeCases =
    describe "remove"
        [ testOperation "removes an item from bench with no active mobsters"
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
        testOperation "without wrapping"
            startList
            NextTurn
            { startList | nextDriver = 1 }


rotateCase2 : Test
rotateCase2 =
    let
        startList =
            { empty | mobsters = [ "Jane Doe", "John Smith" ], nextDriver = 1 }
    in
        testOperation "with wrapping"
            startList
            NextTurn
            { startList | nextDriver = 0 }


rotateCases : Test
rotateCases =
    describe "rotate" [ rotateCase1, rotateCase2 ]


moveCases : Test
moveCases =
    describe "move"
        [ testOperation "single item list"
            { empty | mobsters = [ "only item" ], nextDriver = 0 }
            (Move 0 0)
            { empty | mobsters = [ "only item" ], nextDriver = 0 }
        , testOperation "index not in list"
            { empty | mobsters = [ "a", "b", "d", "c" ], nextDriver = 0 }
            (Move 4 3)
            { empty | mobsters = [ "a", "b", "d", "c" ], nextDriver = 0 }
        , testOperation "multiple items without wrapping"
            { empty | mobsters = [ "a", "b", "d", "c" ], nextDriver = 0 }
            (Move 3 2)
            { empty | mobsters = [ "a", "b", "c", "d" ], nextDriver = 0 }
        , testOperation "placing it below hovered slot when moving from higher to lower"
            { empty | mobsters = [ "a", "b", "c" ], nextDriver = 0 }
            (Move 0 1)
            { empty | mobsters = [ "b", "a", "c" ], nextDriver = 0 }
        , testOperation "to specific position one up"
            { empty | mobsters = [ "a", "b", "c", "d" ], nextDriver = 0 }
            (Move 3 2)
            { empty | mobsters = [ "a", "b", "d", "c" ], nextDriver = 0 }
        , testOperation "to specific position two up"
            { empty | mobsters = [ "a", "b", "c", "d" ], nextDriver = 0 }
            (Move 3 1)
            { empty | mobsters = [ "a", "d", "b", "c" ], nextDriver = 0 }
        , testOperation "down below the last item in list"
            { empty | mobsters = [ "a", "b", "c", "d" ], nextDriver = 0 }
            (Move 0 3)
            { empty | mobsters = [ "b", "c", "d", "a" ], nextDriver = 0 }
        , testOperation "to specific position several slots away"
            { empty | mobsters = [ "a", "b", "c", "d", "e", "f", "g" ], nextDriver = 0 }
            (Move 6 0)
            { empty | mobsters = [ "g", "a", "b", "c", "d", "e", "f" ], nextDriver = 0 }
        ]


addCases : Test
addCases =
    describe "add"
        [ testOperation "add to empty"
            Mobster.empty
            (Add "John Doe")
            { empty | mobsters = [ "John Doe" ] }
        , testOperations "add two things"
            Mobster.empty
            [ (Add "Jane Doe"), (Add "John Smith") ]
            { empty | mobsters = [ "Jane Doe", "John Smith" ], nextDriver = 0 }
        ]


testOperation : String -> MobsterData -> MobsterOperation -> MobsterData -> Test
testOperation description startList operation expectedResult =
    test description <|
        \() ->
            startList
                |> updateMoblist operation
                |> Expect.equal expectedResult


testOperations : String -> MobsterData -> List MobsterOperation -> MobsterData -> Test
testOperations description startList operations expectedResult =
    test description <|
        \() ->
            List.foldl updateMoblist startList operations
                |> Expect.equal expectedResult
