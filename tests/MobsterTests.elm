module MobsterTests exposing (..)

import Test exposing (..)
import Expect
import Mobster exposing (empty)
import MobsterOperation exposing (MobsterOperation(..), updateMoblist)


all : Test
all =
    describe "mobster list"
        [ test "add to empty" <|
            \() ->
                Expect.equal (Mobster.empty |> MobsterOperation.add "John Doe")
                    { empty | mobsters = [ "John Doe" ] }
        , test "add" <|
            \() ->
                Expect.equal
                    (Mobster.empty
                        |> MobsterOperation.add "Jane Doe"
                        |> MobsterOperation.add "John Smith"
                    )
                    { empty | mobsters = [ "Jane Doe", "John Smith" ], nextDriver = 0 }
        , describe "containsName"
            [ test "catches exact matches" <|
                \() ->
                    Mobster.empty
                        |> MobsterOperation.add "Jane"
                        |> Mobster.containsName "Jane"
                        |> Expect.equal True
            , test "catches matches with different casing" <|
                \() ->
                    Mobster.empty
                        |> MobsterOperation.add "jane"
                        |> Mobster.containsName "Jane"
                        |> Expect.equal True
            , test "finds matches on bench" <|
                \() ->
                    { empty | inactiveMobsters = [ "Jane" ] }
                        |> Mobster.containsName "Jane"
                        |> Expect.equal True
            , test "doesn't find false matches" <|
                \() ->
                    Mobster.empty
                        |> MobsterOperation.add "Joe"
                        |> Mobster.containsName "Jane"
                        |> Expect.equal False
            ]
        , describe "get driver and navigator"
            [ test "with two mobsters" <|
                \() ->
                    let
                        startingList =
                            { empty | mobsters = [ "Jane Doe", "John Smith" ] }

                        expectedDriver =
                            { name = "Jane Doe", index = 0 }

                        expectedNavigator =
                            { name = "John Smith", index = 1 }
                    in
                        Expect.equal (Mobster.nextDriverNavigator startingList)
                            { driver = expectedDriver, navigator = expectedNavigator }
            , test "with three mobsters" <|
                \() ->
                    let
                        list =
                            { empty | mobsters = [ "Jane Doe", "John Smith", "Bob Jones" ], nextDriver = 1 }

                        expectedDriver =
                            { name = "John Smith", index = 1 }

                        expectedNavigator =
                            { name = "Bob Jones", index = 2 }
                    in
                        Expect.equal (Mobster.nextDriverNavigator list)
                            { driver = expectedDriver, navigator = expectedNavigator }
            , test "wraps at end of mobster list" <|
                \() ->
                    let
                        list =
                            { empty | mobsters = [ "Jane Doe", "John Smith", "Bob Jones" ], nextDriver = 2 }

                        expectedDriver =
                            { name = "Bob Jones", index = 2 }

                        expectedNavigator =
                            { name = "Jane Doe", index = 0 }
                    in
                        Expect.equal (Mobster.nextDriverNavigator list)
                            { driver = expectedDriver, navigator = expectedNavigator }
            , test "is duplicated with one mobster" <|
                \() ->
                    let
                        startingList =
                            { empty | mobsters = [ "Jane Doe" ], nextDriver = 0 }

                        expectedDriver =
                            { name = "Jane Doe", index = 0 }

                        expectedNavigator =
                            { name = "Jane Doe", index = 0 }
                    in
                        Expect.equal (Mobster.nextDriverNavigator startingList)
                            { driver = expectedDriver, navigator = expectedNavigator }
            , test "uses default with no mobsters" <|
                \() ->
                    let
                        startingList =
                            empty

                        expectedDriver =
                            { name = "", index = -1 }

                        expectedNavigator =
                            { name = "", index = -1 }
                    in
                        Expect.equal (Mobster.nextDriverNavigator startingList)
                            { driver = expectedDriver, navigator = expectedNavigator }
            ]
        , describe "rotate"
            [ test "without wrapping" <|
                \() ->
                    let
                        list =
                            { empty | mobsters = [ "Jane Doe", "John Smith" ], nextDriver = 0 }
                                |> updateMoblist NextTurn
                    in
                        Expect.equal list.nextDriver 1
            , test "with wrapping" <|
                \() ->
                    let
                        updatedList =
                            { empty | mobsters = [ "Jane Doe", "John Smith" ], nextDriver = 1 }
                                |> updateMoblist NextTurn
                    in
                        Expect.equal updatedList.nextDriver 0
            ]
        , describe "move"
            [ test "single item list" <|
                \() ->
                    { empty | mobsters = [ "only item" ], nextDriver = 0 }
                        |> updateMoblist (Move 0 0)
                        |> Expect.equal
                            { empty | mobsters = [ "only item" ], nextDriver = 0 }
            , test "index not in list" <|
                \() ->
                    { empty | mobsters = [ "a", "b", "d", "c" ], nextDriver = 0 }
                        |> updateMoblist (Move 4 3)
                        |> Expect.equal
                            { empty | mobsters = [ "a", "b", "d", "c" ], nextDriver = 0 }
            , test "multiple items without wrapping" <|
                \() ->
                    { empty | mobsters = [ "a", "b", "d", "c" ], nextDriver = 0 }
                        |> updateMoblist (Move 3 2)
                        |> Expect.equal
                            { empty | mobsters = [ "a", "b", "c", "d" ], nextDriver = 0 }
            , test "placing it below hovered slot when moving from higher to lower" <|
                \() ->
                    { empty | mobsters = [ "a", "b", "c" ], nextDriver = 0 }
                        |> updateMoblist (Move 0 1)
                        |> Expect.equal
                            { empty | mobsters = [ "b", "a", "c" ], nextDriver = 0 }
            , test "to specific position one up" <|
                \() ->
                    { empty | mobsters = [ "a", "b", "c", "d" ], nextDriver = 0 }
                        |> updateMoblist (Move 3 2)
                        |> Expect.equal
                            { empty | mobsters = [ "a", "b", "d", "c" ], nextDriver = 0 }
            , test "to specific position two up" <|
                \() ->
                    { empty | mobsters = [ "a", "b", "c", "d" ], nextDriver = 0 }
                        |> updateMoblist (Move 3 1)
                        |> Expect.equal
                            { empty | mobsters = [ "a", "d", "b", "c" ], nextDriver = 0 }
            , test "down below the last item in list" <|
                \() ->
                    { empty | mobsters = [ "a", "b", "c", "d" ], nextDriver = 0 }
                        |> updateMoblist (Move 0 3)
                        |> Expect.equal
                            { empty | mobsters = [ "b", "c", "d", "a" ], nextDriver = 0 }
            , test "to specific position several slots away" <|
                \() ->
                    { empty | mobsters = [ "a", "b", "c", "d", "e", "f", "g" ], nextDriver = 0 }
                        |> updateMoblist (Move 6 0)
                        |> Expect.equal
                            { empty | mobsters = [ "g", "a", "b", "c", "d", "e", "f" ], nextDriver = 0 }
            ]
        , describe "move to inactive"
            [ test "moves a single mobster to an empty bench" <|
                \() ->
                    { empty | mobsters = [ "Spock" ] }
                        |> updateMoblist (Bench 0)
                        |> Expect.equal { empty | inactiveMobsters = [ "Spock" ] }
            , test "puts mobsters on bench in order they are added" <|
                \() ->
                    { empty | mobsters = [ "Kirk", "Spock", "McCoy" ] }
                        |> updateMoblist (Bench 1)
                        |> updateMoblist (Bench 1)
                        |> Expect.equal { empty | mobsters = [ "Kirk" ], inactiveMobsters = [ "Spock", "McCoy" ] }
            ]
        , describe "active"
            [ test "puts mobster back in rotation" <|
                \() ->
                    { empty | inactiveMobsters = [ "Kirk", "Spock", "McCoy" ] }
                        |> updateMoblist (RotateIn 2)
                        |> Expect.equal
                            { empty | inactiveMobsters = [ "Kirk", "Spock" ], mobsters = [ "McCoy" ] }
            , test "adds mobsters back in rotation below the next driver" <|
                \() ->
                    { empty | mobsters = [ "Kirk", "Spock", "McCoy" ], inactiveMobsters = [ "Sulu" ], nextDriver = 1 }
                        |> updateMoblist (RotateIn 0)
                        |> Expect.equal
                            { empty | mobsters = [ "Kirk", "Spock", "Sulu", "McCoy" ], nextDriver = 1 }
            ]
        ]
