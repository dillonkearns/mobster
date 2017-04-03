module BreakTests exposing (all)

import Test exposing (..)
import Expect
import Break


all : Test
all =
    describe "break tests"
        [ describe "timersBeforeNext"
            [ test "just had a break" <|
                \() ->
                    let
                        timersSinceBreak =
                            0

                        timersPerBreakInterval =
                            2

                        result =
                            Break.timersBeforeNext timersSinceBreak timersPerBreakInterval
                    in
                        Expect.equal result 2
            , test "rounds up when going the remaining time doesn't divide evenly into the break interval" <|
                \() ->
                    let
                        timersSinceBreak =
                            1

                        timersPerBreakInterval =
                            4

                        result =
                            Break.timersBeforeNext timersSinceBreak timersPerBreakInterval

                        expected =
                            3
                    in
                        Expect.equal result expected
            , test "break suggested when at least as many intervals have been done as the break interval" <|
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
