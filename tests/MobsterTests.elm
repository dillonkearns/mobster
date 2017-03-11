module MobsterTests exposing (all)

import Test exposing (..)
import Expect
import Mobster.Data as Mobster exposing (empty)


all : Test
all =
    describe "mobster list"
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
