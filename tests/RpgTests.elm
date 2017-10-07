module RpgTests exposing (suite)

import Expect
import Roster.Operation
import Roster.Rpg as Rpg exposing (..)
import Roster.RpgRole exposing (..)
import Test exposing (..)


suite : Test
suite =
    describe "rpg tests"
        [ test "get new card in a fresh session" <|
            \() ->
                let
                    rpgData =
                        Rpg.init
                in
                Expect.true (toString rpgData)
                    (List.all ((==) 0 << .complete) rpgData.driver)
        , test "complete navigator goal" <|
            \() ->
                let
                    rpgData =
                        { driver = [ { complete = 0, description = "driver goal" } ]
                        , navigator = [ { complete = 0, description = "navigator goal" } ]
                        , mobber = [ { complete = 0, description = "mobber goal" } ]
                        , researcher = [ { complete = 0, description = "researcher goal" } ]
                        , sponsor = [ { complete = 0, description = "sponsor goal" } ]
                        }

                    expectedRpgData =
                        { driver = [ { complete = 0, description = "driver goal" } ]
                        , navigator = [ { complete = 1, description = "navigator goal" } ]
                        , mobber = [ { complete = 0, description = "mobber goal" } ]
                        , researcher = [ { complete = 0, description = "researcher goal" } ]
                        , sponsor = [ { complete = 0, description = "sponsor goal" } ]
                        }

                    withCompleted =
                        rpgData
                            |> Roster.Operation.completeGoalInRpgData Navigator 0
                in
                Expect.equal withCompleted expectedRpgData
        , test "complete sponsor goal" <|
            \() ->
                let
                    rpgData =
                        { driver = [ { complete = 0, description = "driver goal" } ]
                        , navigator = [ { complete = 0, description = "navigator goal" } ]
                        , mobber = [ { complete = 0, description = "mobber goal" } ]
                        , researcher = [ { complete = 0, description = "researcher goal" } ]
                        , sponsor = [ { complete = 0, description = "sponsor goal" } ]
                        }

                    expectedRpgData =
                        { driver = [ { complete = 0, description = "driver goal" } ]
                        , navigator = [ { complete = 0, description = "navigator goal" } ]
                        , mobber = [ { complete = 0, description = "mobber goal" } ]
                        , researcher = [ { complete = 0, description = "researcher goal" } ]
                        , sponsor = [ { complete = 1, description = "sponsor goal" } ]
                        }

                    withCompleted =
                        rpgData
                            |> Roster.Operation.completeGoalInRpgData Sponsor 0
                in
                Expect.equal withCompleted expectedRpgData
        , describe "badges"
            [ test "with no complete goals" <|
                \() ->
                    let
                        rpgData =
                            { driver = [ { complete = 0, description = "driver goal" } ]
                            , navigator = [ { complete = 0, description = "navigator goal" } ]
                            , mobber = [ { complete = 0, description = "mobber goal" } ]
                            , researcher = [ { complete = 0, description = "researcher goal" } ]
                            , sponsor = [ { complete = 0, description = "sponsor goal" } ]
                            }
                    in
                    Expect.equal (Rpg.badges rpgData) []
            , test "with one role badge complete" <|
                \() ->
                    let
                        rpgData =
                            { driver =
                                [ { complete = 1, description = "driver goal 1" }
                                , { complete = 1, description = "driver goal 2" }
                                , { complete = 1, description = "driver goal 3" }
                                ]
                            , navigator = [ { complete = 0, description = "navigator goal" } ]
                            , mobber = [ { complete = 0, description = "mobber goal" } ]
                            , researcher = [ { complete = 0, description = "researcher goal" } ]
                            , sponsor = [ { complete = 0, description = "sponsor goal" } ]
                            }
                    in
                    Expect.equal (Rpg.badges rpgData) [ Driver ]
            , test "with multiple role badges complete" <|
                \() ->
                    let
                        rpgData =
                            { driver =
                                [ { complete = 1, description = "driver goal 1" }
                                , { complete = 1, description = "driver goal 2" }
                                , { complete = 1, description = "driver goal 3" }
                                ]
                            , navigator =
                                [ { complete = 1, description = "nav goal 1" }
                                , { complete = 1, description = "nav goal 2" }
                                , { complete = 1, description = "nav goal 3" }
                                ]
                            , mobber = List.repeat 3 { complete = 1, description = "mobber goal" }
                            , researcher = [ { complete = 0, description = "researcher goal" } ]
                            , sponsor = [ { complete = 0, description = "sponsor goal" } ]
                            }
                    in
                    Expect.equal (Rpg.badges rpgData) [ Driver, Navigator, Mobber ]
            ]
        ]
