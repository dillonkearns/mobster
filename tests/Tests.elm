module Tests exposing (..)

import Test exposing (..)
import Expect
import Timer.Main as TimerMain
import Timer.Timer as Timer
import Mobsters


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
        ]


mobsterTests : Test
mobsterTests =
    describe "mobster list"
        [ test "add to empty" <|
            \() ->
                Expect.equal (Mobsters.empty |> Mobsters.add "John Doe")
                    { mobsters = [ "John Doe" ], nextDriver = 0 }
        , test "add" <|
            \() ->
                Expect.equal
                    (Mobsters.empty
                        |> Mobsters.add "Jane Doe"
                        |> Mobsters.add "John Smith"
                    )
                    { mobsters = [ "Jane Doe", "John Smith" ], nextDriver = 0 }
        , describe "get driver and navigator"
            [ test "with two mobsters" <|
                \() ->
                    let
                        startingList =
                            { mobsters = [ "Jane Doe", "John Smith" ], nextDriver = 0 }
                    in
                        Expect.equal (Mobsters.nextDriverNavigator startingList)
                            { driver = "Jane Doe", navigator = "John Smith" }
            , test "with two mobsters" <|
                \() ->
                    let
                        list =
                            { mobsters = [ "Jane Doe", "John Smith", "Bob Jones" ], nextDriver = 1 }
                    in
                        Expect.equal (Mobsters.nextDriverNavigator list)
                            { driver = "John Smith", navigator = "Bob Jones" }
            , test "wraps at end of mobster list" <|
                \() ->
                    let
                        list =
                            { mobsters = [ "Jane Doe", "John Smith", "Bob Jones" ], nextDriver = 2 }
                    in
                        Expect.equal (Mobsters.nextDriverNavigator list)
                            { driver = "Bob Jones", navigator = "Jane Doe" }
            , test "is duplicated with one mobster" <|
                \() ->
                    let
                        startingList =
                            { mobsters = [ "Jane Doe" ], nextDriver = 0 }
                    in
                        Expect.equal (Mobsters.nextDriverNavigator startingList)
                            { driver = "Jane Doe", navigator = "Jane Doe" }
            , test "uses default with no mobsters" <|
                \() ->
                    let
                        startingList =
                            { mobsters = [], nextDriver = 0 }
                    in
                        Expect.equal (Mobsters.nextDriverNavigator startingList)
                            { driver = "", navigator = "" }
            ]
        , describe "rotate"
            [ test "without wrapping" <|
                \() ->
                    let
                        list =
                            { mobsters = [ "Jane Doe", "John Smith" ], nextDriver = 0 }
                    in
                        Expect.equal (Mobsters.rotate list).nextDriver 1
            , test "with wrapping" <|
                \() ->
                    let
                        list =
                            { mobsters = [ "Jane Doe", "John Smith" ], nextDriver = 1 }
                    in
                        Expect.equal (Mobsters.rotate list).nextDriver 0
            ]
        , describe "move"
            [ test "single item list" <|
                \() ->
                    let
                        list =
                            { mobsters = [ "only item" ], nextDriver = 0 }
                    in
                        Expect.equal (list |> Mobsters.moveUp 0)
                            { mobsters = [ "only item" ], nextDriver = 0 }
            , test "index not in list" <|
                \() ->
                    let
                        list =
                            { mobsters = [ "a", "b", "d", "c" ], nextDriver = 0 }
                    in
                        Expect.equal (list |> Mobsters.moveUp 4)
                            { mobsters = [ "a", "b", "d", "c" ], nextDriver = 0 }
            , test "multiple items without wrapping" <|
                \() ->
                    let
                        list =
                            { mobsters = [ "a", "b", "d", "c" ], nextDriver = 0 }
                    in
                        Expect.equal (list |> Mobsters.moveUp 3)
                            { mobsters = [ "a", "b", "c", "d" ], nextDriver = 0 }
            ]
        ]
