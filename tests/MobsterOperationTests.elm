module MobsterOperationTests exposing (all)

import Test exposing (..)
import Expect
import Mobster.Data as Mobster exposing (MobsterData, empty)
import Mobster.Operation exposing (MobsterOperation(..), updateMoblist)
import TestHelpers exposing (toMobsters)
import Mobster.RpgRole exposing (..)


fakeExperience =
    { driver = [ { complete = False, description = "driver goal" } ]
    , navigator = [ { complete = False, description = "navigator goal" } ]
    , mobber = [ { complete = False, description = "mobber goal" } ]
    , researcher = [ { complete = False, description = "researcher goal" } ]
    , sponsor = [ { complete = False, description = "sponsor goal" } ]
    }


fakeExperience2 =
    { driver = [ { complete = True, description = "driver goal" } ]
    , navigator = [ { complete = False, description = "navigator goal" } ]
    , mobber = [ { complete = False, description = "mobber goal" } ]
    , researcher = [ { complete = False, description = "researcher goal" } ]
    , sponsor = [ { complete = False, description = "sponsor goal" } ]
    }


createMobster : String -> Mobster.Mobster
createMobster name =
    Mobster.Mobster name fakeExperience


all : Test
all =
    describe "mobster operation" [ benchCases, rotateInCases, removeCases, rotateCases, moveCases, addCases, completeGoalCases ]


completeGoalCases : Test
completeGoalCases =
    describe "complete goal"
        [ testOperation "driver doesn't change when navigator is removed"
            { empty
                | mobsters = [ createMobster "Sulu", createMobster "Kirk", createMobster "Spock", createMobster "McCoy" ]
            }
            (CompleteGoal 0 Driver 0)
            { empty
                | mobsters =
                    [ Mobster.Mobster "Sulu" fakeExperience2
                    , createMobster "Kirk"
                    , createMobster "Spock"
                    , createMobster "McCoy"
                    ]
            }
        ]


benchCases : Test
benchCases =
    describe "bench"
        [ testOperation "driver doesn't change when navigator is removed"
            { empty | mobsters = [ "Kirk", "Spock", "McCoy" ] |> toMobsters }
            (Bench 1)
            { empty | mobsters = [ "Kirk", "McCoy" ] |> toMobsters, inactiveMobsters = [ "Spock" ] |> toMobsters, nextDriver = 0 }
        , testOperation "wraps around list for next driver when nextDriver is removed and was at end of list"
            { empty | mobsters = [ "Kirk", "Spock", "McCoy" ] |> toMobsters, nextDriver = 2 }
            (Bench 2)
            { empty | mobsters = [ "Kirk", "Spock" ] |> toMobsters, inactiveMobsters = [ "McCoy" ] |> toMobsters, nextDriver = 0 }
        , testOperation "moves a single mobster to an empty bench"
            { empty | mobsters = [ "Spock" ] |> toMobsters }
            (Bench 0)
            { empty | inactiveMobsters = [ "Spock" ] |> toMobsters }
        , testOperation "moves the mobster with the correct index"
            { empty | mobsters = [ "Spock", "Sulu" ] |> toMobsters }
            (Bench 0)
            { empty | mobsters = [ "Sulu" ] |> toMobsters, inactiveMobsters = [ "Spock" ] |> toMobsters }
        , testOperations "puts mobsters on bench in order they are added"
            { empty | mobsters = [ "Kirk", "Spock", "McCoy" ] |> toMobsters }
            [ (Bench 1), (Bench 1) ]
            { empty | mobsters = [ "Kirk" ] |> toMobsters, inactiveMobsters = [ "Spock", "McCoy" ] |> toMobsters }
        ]


rotateInCases : Test
rotateInCases =
    describe "rotate in"
        [ testOperation "puts mobster back in rotation"
            { empty | inactiveMobsters = [ "Kirk", "Spock", "McCoy" ] |> toMobsters }
            (RotateIn 2)
            { empty | inactiveMobsters = [ "Kirk", "Spock" ] |> toMobsters, mobsters = [ "McCoy" ] |> toMobsters }
        , testOperation "adds mobsters back in rotation below the next driver"
            { empty | mobsters = [ "Kirk", "Spock", "McCoy" ] |> toMobsters, inactiveMobsters = [ "Sulu" ] |> toMobsters, nextDriver = 1 }
            (RotateIn 0)
            { empty | mobsters = [ "Kirk", "Spock", "Sulu", "McCoy" ] |> toMobsters, nextDriver = 1 }
        ]


removeCases : Test
removeCases =
    describe "remove"
        [ testOperation "removes an item from bench with no active mobsters"
            { empty | inactiveMobsters = [ "Kirk", "Spock", "McCoy" ] |> toMobsters }
            (Remove 1)
            { empty | inactiveMobsters = [ "Kirk", "McCoy" ] |> toMobsters }
        ]


rotateCase1 : Test
rotateCase1 =
    let
        startList =
            { empty | mobsters = [ "Jane Doe", "John Smith" ] |> toMobsters, nextDriver = 0 }
    in
        testOperation "without wrapping"
            startList
            NextTurn
            { startList | nextDriver = 1 }


rotateCase2 : Test
rotateCase2 =
    let
        startList =
            { empty | mobsters = [ "Jane Doe", "John Smith" ] |> toMobsters, nextDriver = 1 }
    in
        testOperation "with wrapping"
            startList
            NextTurn
            { startList | nextDriver = 0 }


rotateCase3 : Test
rotateCase3 =
    let
        startList =
            { empty | mobsters = [ "Kirk", "Spock", "McCoy" ] |> toMobsters, nextDriver = 1 }
    in
        testOperation "rewind"
            startList
            RewindTurn
            { startList | nextDriver = 0 }


rotateCases : Test
rotateCases =
    describe "rotate" [ rotateCase1, rotateCase2, rotateCase3 ]


moveCases : Test
moveCases =
    describe "move"
        [ testOperation "single item list"
            { empty | mobsters = [ "only item" ] |> toMobsters, nextDriver = 0 }
            (Move 0 0)
            { empty | mobsters = [ "only item" ] |> toMobsters, nextDriver = 0 }
        , testOperation "index not in list"
            { empty | mobsters = [ "a", "b", "d", "c" ] |> toMobsters, nextDriver = 0 }
            (Move 4 3)
            { empty | mobsters = [ "a", "b", "d", "c" ] |> toMobsters, nextDriver = 0 }
        , testOperation "multiple items without wrapping"
            { empty | mobsters = [ "a", "b", "d", "c" ] |> toMobsters, nextDriver = 0 }
            (Move 3 2)
            { empty | mobsters = [ "a", "b", "c", "d" ] |> toMobsters, nextDriver = 0 }
        , testOperation "placing it below hovered slot when moving from higher to lower"
            { empty | mobsters = [ "a", "b", "c" ] |> toMobsters, nextDriver = 0 }
            (Move 0 1)
            { empty | mobsters = [ "b", "a", "c" ] |> toMobsters, nextDriver = 0 }
        , testOperation "to specific position one up"
            { empty | mobsters = [ "a", "b", "c", "d" ] |> toMobsters, nextDriver = 0 }
            (Move 3 2)
            { empty | mobsters = [ "a", "b", "d", "c" ] |> toMobsters, nextDriver = 0 }
        , testOperation "to specific position two up"
            { empty | mobsters = [ "a", "b", "c", "d" ] |> toMobsters, nextDriver = 0 }
            (Move 3 1)
            { empty | mobsters = [ "a", "d", "b", "c" ] |> toMobsters, nextDriver = 0 }
        , testOperation "down below the last item in list"
            { empty | mobsters = [ "a", "b", "c", "d" ] |> toMobsters, nextDriver = 0 }
            (Move 0 3)
            { empty | mobsters = [ "b", "c", "d", "a" ] |> toMobsters, nextDriver = 0 }
        , testOperation "to specific position several slots away"
            { empty | mobsters = [ "a", "b", "c", "d", "e", "f", "g" ] |> toMobsters, nextDriver = 0 }
            (Move 6 0)
            { empty | mobsters = [ "g", "a", "b", "c", "d", "e", "f" ] |> toMobsters, nextDriver = 0 }
        ]


addCases : Test
addCases =
    describe "add"
        [ testOperation "add to empty"
            Mobster.empty
            (Add "John Doe")
            { empty | mobsters = [ "John Doe" ] |> toMobsters }
        , testOperations "add two things"
            Mobster.empty
            [ (Add "Jane Doe"), (Add "John Smith") ]
            { empty | mobsters = [ "Jane Doe", "John Smith" ] |> toMobsters, nextDriver = 0 }
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
