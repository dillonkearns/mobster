module BreakTests exposing (suite)

import Break
import Expect
import Test exposing (..)


suite : Test
suite =
    describe "break tests"
        [ describe "timersBeforeNext"
            [ test "break suggested when at least as many intervals have been done as the break interval" <|
                \() ->
                    let
                        timersSinceBreak =
                            12

                        timersPerBreakInterval =
                            10

                        result =
                            Break.breakSuggested timersSinceBreak timersPerBreakInterval
                    in
                    Expect.equal result True
            , test "break not suggested when fewer intervals have been completed than break interval" <|
                \() ->
                    let
                        timersSinceBreak =
                            9

                        timersPerBreakInterval =
                            10

                        result =
                            Break.breakSuggested timersSinceBreak timersPerBreakInterval
                    in
                    Expect.equal result False
            , test "break not suggested when value set to 0" <|
                \() ->
                    let
                        timersSinceBreak =
                            1000

                        timersPerBreakInterval =
                            0

                        result =
                            Break.breakSuggested timersSinceBreak timersPerBreakInterval
                    in
                    Expect.equal result False
            ]
        ]
