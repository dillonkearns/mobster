module TimerTests exposing (suite)

import Expect
import Test exposing (..)
import Timer.Timer as Timer


suite : Test
suite =
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
                    Expect.equal (Timer.updateTimer 123) 122
            , test "timer decrements for another value" <|
                \() ->
                    Expect.equal (Timer.updateTimer 10) 9
            ]
        ]
