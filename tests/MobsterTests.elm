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
        ]
