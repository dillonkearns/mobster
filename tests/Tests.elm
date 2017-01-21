module Tests exposing (..)

import Test exposing (..)
import Expect
import Timer


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
        ]
