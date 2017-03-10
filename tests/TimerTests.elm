module TimerTests exposing (all)

import Test exposing (..)
import Expect
import Timer.Main as TimerMain
import Timer.Timer as Timer


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
        ]
