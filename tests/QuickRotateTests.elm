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
                    |> .selection
                    |> Expect.equal QuickRotate.All
        , test "selects first match with multiple matches" <|
            \() ->
                QuickRotate.init
                    |> QuickRotate.update "query" [ "query1", "query2", "def" ]
                    |> .selection
                    |> Expect.equal (QuickRotate.Index 0)
        , test "selects first match with only one match" <|
            \() ->
                QuickRotate.init
                    |> QuickRotate.update "query" [ "abc", "query", "def" ]
                    |> .selection
                    |> Expect.equal (QuickRotate.Index 1)
        , test "selects New when there are no matches" <|
            \() ->
                QuickRotate.init
                    |> QuickRotate.update "query without a match" [ "and now", "something completely different" ]
                    |> .selection
                    |> Expect.equal (QuickRotate.New "query without a match")
        , test "selects second match after calling next" <|
            \() ->
                QuickRotate.init
                    |> QuickRotate.update "query" [ "query1", "query2", "def" ]
                    |> QuickRotate.next [ "query1", "query2", "def" ]
                    |> Expect.equal { selection = (QuickRotate.Index 1), query = "query" }
        , test "finds next when matches start from the middle" <|
            \() ->
                QuickRotate.init
                    |> QuickRotate.update "query" [ "asdf", "query1", "query2" ]
                    |> QuickRotate.next [ "asdf", "query1", "query2" ]
                    |> Expect.equal { selection = (QuickRotate.Index 2), query = "query" }
        , test "next wraps around to new" <|
            \() ->
                { query = "query", selection = QuickRotate.Index 2 }
                    |> QuickRotate.next [ "asdf", "query1", "query2" ]
                    |> Expect.equal { query = "query", selection = (QuickRotate.New "query") }
        , test "next wraps around from new to first match" <|
            \() ->
                { query = "query", selection = QuickRotate.New "query" }
                    |> QuickRotate.next [ "asdf", "query1", "query2" ]
                    |> Expect.equal { query = "query", selection = (QuickRotate.Index 1) }
        , test "gives you indices of matches" <|
            \() ->
                QuickRotate.init
                    |> QuickRotate.update "query" [ "query1", "query2", "def" ]
                    |> QuickRotate.matches [ "query1", "query2", "def" ]
                    |> Expect.equal [ 0, 1 ]
        ]
