module MobsterPresenterTests exposing (all)

import Expect
import Roster.Data as Mobster exposing (empty)
import Roster.Presenter
import Test exposing (..)
import TestHelpers exposing (toMobsters)


all : Test
all =
    describe "get driver and navigator"
        [ test "with two mobsters" <|
            \() ->
                let
                    startingList =
                        { empty | mobsters = [ "Jane Doe", "John Smith" ] |> toMobsters }

                    expectedDriver =
                        { name = "Jane Doe", index = 0 }

                    expectedNavigator =
                        { name = "John Smith", index = 1 }
                in
                Expect.equal (Roster.Presenter.nextDriverNavigator startingList)
                    { driver = expectedDriver, navigator = expectedNavigator }
        , test "with three mobsters" <|
            \() ->
                let
                    list =
                        { empty | mobsters = [ "Jane Doe", "John Smith", "Bob Jones" ] |> toMobsters, nextDriver = 1 }

                    expectedDriver =
                        { name = "John Smith", index = 1 }

                    expectedNavigator =
                        { name = "Bob Jones", index = 2 }
                in
                Expect.equal (Roster.Presenter.nextDriverNavigator list)
                    { driver = expectedDriver, navigator = expectedNavigator }
        , test "wraps at end of mobster list" <|
            \() ->
                let
                    list =
                        { empty | mobsters = [ "Jane Doe", "John Smith", "Bob Jones" ] |> toMobsters, nextDriver = 2 }

                    expectedDriver =
                        { name = "Bob Jones", index = 2 }

                    expectedNavigator =
                        { name = "Jane Doe", index = 0 }
                in
                Expect.equal (Roster.Presenter.nextDriverNavigator list)
                    { driver = expectedDriver, navigator = expectedNavigator }
        , test "is duplicated with one mobster" <|
            \() ->
                let
                    startingList =
                        { empty | mobsters = [ "Jane Doe" ] |> toMobsters, nextDriver = 0 }

                    expectedDriver =
                        { name = "Jane Doe", index = 0 }

                    expectedNavigator =
                        { name = "Jane Doe", index = 0 }
                in
                Expect.equal (Roster.Presenter.nextDriverNavigator startingList)
                    { driver = expectedDriver, navigator = expectedNavigator }
        , test "uses default with no mobsters" <|
            \() ->
                let
                    startingList =
                        empty

                    expectedDriver =
                        { name = "", index = -1 }

                    expectedNavigator =
                        { name = "", index = -1 }
                in
                Expect.equal (Roster.Presenter.nextDriverNavigator startingList)
                    { driver = expectedDriver, navigator = expectedNavigator }
        ]
