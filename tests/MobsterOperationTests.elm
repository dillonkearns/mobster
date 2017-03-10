module MobsterOperationTests exposing (all)

import Test exposing (..)
import Expect
import Mobster exposing (MobsterData, empty)
import MobsterOperation exposing (MobsterOperation(..), updateMoblist)


all : Test
all =
    describe "mobster operation" [ removeTests ]


removeTests : Test
removeTests =
    describe "remove"
        [ test "list with single item" <|
            \() ->
                { empty | mobsters = [ "only item" ] }
                    |> updateMoblist (Bench 0)
                    |> Expect.equal
                        { empty | inactiveMobsters = [ "only item" ], nextDriver = 0 }
        , test "with multiple items" <|
            \() ->
                { empty | mobsters = [ "first", "second" ] }
                    |> updateMoblist (Bench 0)
                    |> Expect.equal
                        { empty | mobsters = [ "second" ], inactiveMobsters = [ "first" ], nextDriver = 0 }
        , test "driver doesn't change when navigator is removed" <|
            \() ->
                { empty | mobsters = [ "Kirk", "Spock", "McCoy" ] }
                    |> updateMoblist (Bench 1)
                    |> Expect.equal
                        { empty | mobsters = [ "Kirk", "McCoy" ], inactiveMobsters = [ "Spock" ], nextDriver = 0 }
        , test "wraps around list for next driver when nextDriver is removed and was at end of list" <|
            \() ->
                { empty | mobsters = [ "Kirk", "Spock", "McCoy" ], nextDriver = 2 }
                    |> updateMoblist (Bench 2)
                    |> Expect.equal
                        { empty | mobsters = [ "Kirk", "Spock" ], inactiveMobsters = [ "McCoy" ], nextDriver = 0 }
        ]


mobsterOperationTest : MobsterData -> MobsterData -> String -> MobsterOperation -> Test
mobsterOperationTest startList expectedResult description operation =
    test description <|
        \() ->
            startList
                |> updateMoblist operation
                |> Expect.equal
                    expectedResult
