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
        ]
