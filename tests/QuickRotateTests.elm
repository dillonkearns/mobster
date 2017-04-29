module QuickRotateTests exposing (all)

import Expect
import QuickRotate
import Test exposing (describe, test, Test)


all : Test
all =
    describe "Quick rotate"
        [ test "all selected on init" <|
            \() ->
                QuickRotate.init
                    |> Expect.equal QuickRotate.All
        , test "selects first match with multiple matches" <|
            \() ->
                QuickRotate.init
                    |> QuickRotate.update "query" [ "query1", "query2", "def" ]
                    |> Expect.equal (QuickRotate.Index 0)
        , test "selects first match with only one match" <|
            \() ->
                QuickRotate.init
                    |> QuickRotate.update "query" [ "abc", "query", "def" ]
                    |> Expect.equal (QuickRotate.Index 1)
        , test "selects New when there are no matches" <|
            \() ->
                QuickRotate.init
                    |> QuickRotate.update "query without a match" [ "and now", "something completely different" ]
                    |> Expect.equal (QuickRotate.New "query without a match")
        ]
