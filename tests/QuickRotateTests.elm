module QuickRotateTests exposing (suite)

import Expect
import QuickRotate
import Test exposing (describe, test, Test)


suite : Test
suite =
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
                    |> Expect.equal { selection = QuickRotate.Index 1, query = "query" }
        , test "finds next when matches start from the middle" <|
            \() ->
                QuickRotate.init
                    |> QuickRotate.update "query" [ "asdf", "query1", "query2" ]
                    |> QuickRotate.next [ "asdf", "query1", "query2" ]
                    |> Expect.equal { selection = QuickRotate.Index 2, query = "query" }
        , test "next wraps around to new" <|
            \() ->
                { query = "query", selection = QuickRotate.Index 2 }
                    |> QuickRotate.next [ "asdf", "query1", "query2" ]
                    |> Expect.equal { query = "query", selection = (QuickRotate.New "query") }
        , test "previous rotates back to new first" <|
            \() ->
                QuickRotate.init
                    |> QuickRotate.update "query" [ "asdf", "query1", "query2" ]
                    |> QuickRotate.previous [ "asdf", "query1", "query2" ]
                    |> Expect.equal { selection = QuickRotate.New "query", query = "query" }
        , test "previous rotates back by one" <|
            \() ->
                { query = "query", selection = QuickRotate.Index 2 }
                    |> QuickRotate.previous [ "asdf", "query1", "query2" ]
                    |> Expect.equal { query = "query", selection = QuickRotate.Index 1 }
        , test "next wraps around from new to first match" <|
            \() ->
                { query = "query", selection = QuickRotate.New "query" }
                    |> QuickRotate.next [ "asdf", "query1", "query2" ]
                    |> Expect.equal { query = "query", selection = QuickRotate.Index 1 }
        , test "next from no selection" <|
            \() ->
                QuickRotate.init
                    |> QuickRotate.next [ "asdf", "query1", "query2" ]
                    |> Expect.equal { query = "", selection = QuickRotate.Index 0 }
        , test "previous skips new from All when query is empty" <|
            \() ->
                QuickRotate.init
                    |> QuickRotate.previous [ "asdf", "query1", "query2" ]
                    |> Expect.equal { query = "", selection = QuickRotate.Index 2 }
        , test "previous skips over new query when empty" <|
            \() ->
                { query = "", selection = QuickRotate.Index 0 }
                    |> QuickRotate.previous [ "asdf", "query1", "query2" ]
                    |> Expect.equal { query = "", selection = QuickRotate.Index 2 }
        , test "next skips over new query when empty" <|
            \() ->
                { query = "", selection = QuickRotate.Index 2 }
                    |> QuickRotate.next [ "asdf", "query1", "query2" ]
                    |> Expect.equal { query = "", selection = QuickRotate.Index 0 }
        , test "clearing query from new selection with an empty list deselects it" <|
            \() ->
                { query = "some query", selection = QuickRotate.New "" }
                    |> QuickRotate.update "" []
                    |> Expect.equal { query = "", selection = QuickRotate.All }
        , test "clearing query from Index selection deselects it" <|
            \() ->
                { query = "some query", selection = QuickRotate.Index 1 }
                    |> QuickRotate.update "" [ "Item 1", "Item 2" ]
                    |> Expect.equal { query = "", selection = QuickRotate.All }
        , test "gives you indices of matches" <|
            \() ->
                QuickRotate.init
                    |> QuickRotate.update "query" [ "query1", "query2", "def" ]
                    |> QuickRotate.matches [ "query1", "query2", "def" ]
                    |> Expect.equal [ 0, 1 ]
        ]
