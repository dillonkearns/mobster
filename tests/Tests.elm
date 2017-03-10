module Tests exposing (..)

import Test exposing (..)
import Expect
import Timer.Main as TimerMain
import Timer.Timer as Timer
import Mobster exposing (MobsterOperation(..), empty)
import BreakTests
import SettingsDecodeTests


all : Test
all =
    describe "timer"
        [ describe "convert seconds to timer"
            [ test "with minutes" <|
                \() ->
                    Expect.equal (Timer.secondsToTimer 60) (Timer.Timer 1 0)
            , test "with minutes and seconds" <|
                \() ->
                    Expect.equal (Timer.secondsToTimer 181) (Timer.Timer 3 1)
            ]
        , describe "tick"
            [ test "timer decrements" <|
                \() ->
                    Expect.equal (TimerMain.updateTimer 123) 122
            , test "timer decrements for another value" <|
                \() ->
                    Expect.equal (TimerMain.updateTimer 10) 9
            ]
        , mobsterTests
        , BreakTests.cases
        , SettingsDecodeTests.cases
        ]


mobsterTests : Test
mobsterTests =
    describe "mobster list"
        [ test "add to empty" <|
            \() ->
                Expect.equal (Mobster.empty |> Mobster.add "John Doe")
                    { empty | mobsters = [ "John Doe" ] }
        , test "add" <|
            \() ->
                Expect.equal
                    (Mobster.empty
                        |> Mobster.add "Jane Doe"
                        |> Mobster.add "John Smith"
                    )
                    { empty | mobsters = [ "Jane Doe", "John Smith" ], nextDriver = 0 }
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
                    in
                        Expect.equal (Mobster.rotate list).nextDriver 1
            , test "with wrapping" <|
                \() ->
                    let
                        list =
                            { empty | mobsters = [ "Jane Doe", "John Smith" ], nextDriver = 1 }
                    in
                        Expect.equal (Mobster.rotate list).nextDriver 0
            ]
        , describe "move"
            [ test "single item list" <|
                \() ->
                    { empty | mobsters = [ "only item" ], nextDriver = 0 }
                        |> Mobster.updateMoblist (Move 0 0)
                        |> Expect.equal
                            { empty | mobsters = [ "only item" ], nextDriver = 0 }
            , test "index not in list" <|
                \() ->
                    { empty | mobsters = [ "a", "b", "d", "c" ], nextDriver = 0 }
                        |> Mobster.updateMoblist (Move 4 3)
                        |> Expect.equal
                            { empty | mobsters = [ "a", "b", "d", "c" ], nextDriver = 0 }
            , test "multiple items without wrapping" <|
                \() ->
                    { empty | mobsters = [ "a", "b", "d", "c" ], nextDriver = 0 }
                        |> Mobster.updateMoblist (Move 3 2)
                        |> Expect.equal
                            { empty | mobsters = [ "a", "b", "c", "d" ], nextDriver = 0 }
            , test "placing it below hovered slot when moving from higher to lower" <|
                \() ->
                    { empty | mobsters = [ "a", "b", "c" ], nextDriver = 0 }
                        |> Mobster.updateMoblist (Move 0 1)
                        |> Expect.equal
                            { empty | mobsters = [ "b", "a", "c" ], nextDriver = 0 }
            , test "to specific position one up" <|
                \() ->
                    { empty | mobsters = [ "a", "b", "c", "d" ], nextDriver = 0 }
                        |> Mobster.updateMoblist (Move 3 2)
                        |> Expect.equal
                            { empty | mobsters = [ "a", "b", "d", "c" ], nextDriver = 0 }
            , test "to specific position two up" <|
                \() ->
                    { empty | mobsters = [ "a", "b", "c", "d" ], nextDriver = 0 }
                        |> Mobster.updateMoblist (Move 3 1)
                        |> Expect.equal
                            { empty | mobsters = [ "a", "d", "b", "c" ], nextDriver = 0 }
            , test "down below the last item in list" <|
                \() ->
                    { empty | mobsters = [ "a", "b", "c", "d" ], nextDriver = 0 }
                        |> Mobster.updateMoblist (Move 0 3)
                        |> Expect.equal
                            { empty | mobsters = [ "b", "c", "d", "a" ], nextDriver = 0 }
            , test "to specific position several slots away" <|
                \() ->
                    { empty | mobsters = [ "a", "b", "c", "d", "e", "f", "g" ], nextDriver = 0 }
                        |> Mobster.updateMoblist (Move 6 0)
                        |> Expect.equal
                            { empty | mobsters = [ "g", "a", "b", "c", "d", "e", "f" ], nextDriver = 0 }
            ]
        , describe "remove"
            [ test "list with single item" <|
                \() ->
                    { empty | mobsters = [ "only item" ] }
                        |> Mobster.updateMoblist (Bench 0)
                        |> Expect.equal
                            { empty | inactiveMobsters = [ "only item" ], nextDriver = 0 }
            , test "with multiple items" <|
                \() ->
                    { empty | mobsters = [ "first", "second" ] }
                        |> Mobster.updateMoblist (Bench 0)
                        |> Expect.equal
                            { empty | mobsters = [ "second" ], inactiveMobsters = [ "first" ], nextDriver = 0 }
            , test "driver doesn't change when navigator is removed" <|
                \() ->
                    { empty | mobsters = [ "Kirk", "Spock", "McCoy" ] }
                        |> Mobster.updateMoblist (Bench 1)
                        |> Expect.equal
                            { empty | mobsters = [ "Kirk", "McCoy" ], inactiveMobsters = [ "Spock" ], nextDriver = 0 }
            , test "wraps around list for next driver when nextDriver is removed and was at end of list" <|
                \() ->
                    { empty | mobsters = [ "Kirk", "Spock", "McCoy" ], nextDriver = 2 }
                        |> Mobster.updateMoblist (Bench 2)
                        |> Expect.equal
                            { empty | mobsters = [ "Kirk", "Spock" ], inactiveMobsters = [ "McCoy" ], nextDriver = 0 }
            ]
        , describe "move to inactive"
            [ test "moves a single mobster to an empty bench" <|
                \() ->
                    { empty | mobsters = [ "Spock" ] }
                        |> Mobster.updateMoblist (Bench 0)
                        |> Expect.equal { empty | inactiveMobsters = [ "Spock" ] }
            , test "puts mobsters on bench in order they are added" <|
                \() ->
                    { empty | mobsters = [ "Kirk", "Spock", "McCoy" ] }
                        |> Mobster.updateMoblist (Bench 1)
                        |> Mobster.updateMoblist (Bench 1)
                        |> Expect.equal { empty | mobsters = [ "Kirk" ], inactiveMobsters = [ "Spock", "McCoy" ] }
            ]
        , describe "remove"
            [ test "removes an item from bench with no active mobsters" <|
                \() ->
                    { empty | inactiveMobsters = [ "Kirk", "Spock", "McCoy" ] }
                        |> Mobster.updateMoblist (Remove 1)
                        |> Expect.equal { empty | inactiveMobsters = [ "Kirk", "McCoy" ] }
            ]
        , describe "active"
            [ test "puts mobster back in rotation" <|
                \() ->
                    { empty | inactiveMobsters = [ "Kirk", "Spock", "McCoy" ] }
                        |> Mobster.updateMoblist (RotateIn 2)
                        |> Expect.equal
                            { empty | inactiveMobsters = [ "Kirk", "Spock" ], mobsters = [ "McCoy" ] }
            ]
        ]
