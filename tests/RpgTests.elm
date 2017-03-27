module RpgTests exposing (all)

import Expect
import Mobster.Rpg as Rpg exposing (..)
import Mobster.RpgRole exposing (..)
import Mobster.Rpg
import Test exposing (..)
import Mobster.Operation


all : Test
all =
    describe "rpg tests"
        [ test "get new card in a fresh session" <|
            \() ->
                let
                    rpgData =
                        Rpg.init
                in
                    Expect.true (toString rpgData)
                        (List.all (not << .complete) rpgData.driver)
        , test "complete navigator goal" <|
            \() ->
                let
                    rpgData =
                        { driver = [ { complete = False, description = "driver goal" } ]
                        , navigator = [ { complete = False, description = "navigator goal" } ]
                        , mobber = [ { complete = False, description = "mobber goal" } ]
                        , researcher = [ { complete = False, description = "researcher goal" } ]
                        , sponsor = [ { complete = False, description = "sponsor goal" } ]
                        }

                    expectedRpgData =
                        { driver = [ { complete = False, description = "driver goal" } ]
                        , navigator = [ { complete = True, description = "navigator goal" } ]
                        , mobber = [ { complete = False, description = "mobber goal" } ]
                        , researcher = [ { complete = False, description = "researcher goal" } ]
                        , sponsor = [ { complete = False, description = "sponsor goal" } ]
                        }

                    withCompleted =
                        rpgData
                            |> Mobster.Operation.completeGoalInRpgData Navigator 0
                in
                    Expect.equal withCompleted expectedRpgData
        , test "complete sponsor goal" <|
            \() ->
                let
                    rpgData =
                        { driver = [ { complete = False, description = "driver goal" } ]
                        , navigator = [ { complete = False, description = "navigator goal" } ]
                        , mobber = [ { complete = False, description = "mobber goal" } ]
                        , researcher = [ { complete = False, description = "researcher goal" } ]
                        , sponsor = [ { complete = False, description = "sponsor goal" } ]
                        }

                    expectedRpgData =
                        { driver = [ { complete = False, description = "driver goal" } ]
                        , navigator = [ { complete = False, description = "navigator goal" } ]
                        , mobber = [ { complete = False, description = "mobber goal" } ]
                        , researcher = [ { complete = False, description = "researcher goal" } ]
                        , sponsor = [ { complete = True, description = "sponsor goal" } ]
                        }

                    withCompleted =
                        rpgData
                            |> Mobster.Operation.completeGoalInRpgData Sponsor 0
                in
                    Expect.equal withCompleted expectedRpgData
        , describe "badges"
            [ test "with no complete goals" <|
                \() ->
                    let
                        rpgData =
                            { driver = [ { complete = False, description = "driver goal" } ]
                            , navigator = [ { complete = False, description = "navigator goal" } ]
                            , mobber = [ { complete = False, description = "mobber goal" } ]
                            , researcher = [ { complete = False, description = "researcher goal" } ]
                            , sponsor = [ { complete = False, description = "sponsor goal" } ]
                            }
                    in
                        Expect.equal (Mobster.Rpg.badges rpgData) []
            , test "with one role badge complete" <|
                \() ->
                    let
                        rpgData =
                            { driver =
                                [ { complete = True, description = "driver goal 1" }
                                , { complete = True, description = "driver goal 2" }
                                , { complete = True, description = "driver goal 3" }
                                ]
                            , navigator = [ { complete = False, description = "navigator goal" } ]
                            , mobber = [ { complete = False, description = "mobber goal" } ]
                            , researcher = [ { complete = False, description = "researcher goal" } ]
                            , sponsor = [ { complete = False, description = "sponsor goal" } ]
                            }
                    in
                        Expect.equal (Mobster.Rpg.badges rpgData) [ Driver ]
            , test "with multiple role badges complete" <|
                \() ->
                    let
                        rpgData =
                            { driver =
                                [ { complete = True, description = "driver goal 1" }
                                , { complete = True, description = "driver goal 2" }
                                , { complete = True, description = "driver goal 3" }
                                ]
                            , navigator =
                                [ { complete = True, description = "nav goal 1" }
                                , { complete = True, description = "nav goal 2" }
                                , { complete = True, description = "nav goal 3" }
                                ]
                            , mobber = (List.repeat 3 { complete = True, description = "mobber goal" })
                            , researcher = [ { complete = False, description = "researcher goal" } ]
                            , sponsor = [ { complete = False, description = "sponsor goal" } ]
                            }
                    in
                        Expect.equal (Mobster.Rpg.badges rpgData) [ Driver, Navigator, Mobber ]
            ]
        ]
