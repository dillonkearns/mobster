module BreakTests exposing (cases)

import Test exposing (..)
import Expect
import Break


cases : Test
cases =
    describe "break tests" [ timersBeforeNextCases ]


timersBeforeNextCases : Test
timersBeforeNextCases =
    describe "timersBeforeNext"
        [ test "just had a break" <|
            \() ->
                let
                    minutesSinceBreak =
                        0

                    timerDuration =
                        1

                    breakInterval =
                        2

                    result =
                        Break.timersBeforeNext minutesSinceBreak timerDuration breakInterval
                in
                    Expect.equal result ( 2, 2 )
        , test "rounds up when going the remaining time doesn't divide evenly into the break interval" <|
            \() ->
                let
                    minutesSinceBreak =
                        1

                    timerDuration =
                        5

                    breakInterval =
                        20

                    result =
                        Break.timersBeforeNext minutesSinceBreak timerDuration breakInterval

                    expected =
                        ( 4, 4 )
                in
                    Expect.equal result expected
        , test "remaining timers is 0 when time since break is over break interval" <|
            \() ->
                let
                    minutesSinceBreak =
                        30

                    timerDuration =
                        5

                    breakInterval =
                        20

                    result =
                        Break.timersBeforeNext minutesSinceBreak timerDuration breakInterval
                in
                    Expect.equal result ( 0, 4 )
        ]
