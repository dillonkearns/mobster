module RpgTests exposing (all)

import Expect
import Mobster.Rpg as Rpg exposing (..)
import Mobster.RpgPresenter
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
                        , researcher = [ { complete = False, description = "researcher goal" } ]
                        , sponsor = [ { complete = False, description = "sponsor goal" } ]
                        }

                    expectedRpgData =
                        { driver = [ { complete = False, description = "driver goal" } ]
                        , navigator = [ { complete = True, description = "navigator goal" } ]
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
                        , researcher = [ { complete = False, description = "researcher goal" } ]
                        , sponsor = [ { complete = False, description = "sponsor goal" } ]
                        }

                    expectedRpgData =
                        { driver = [ { complete = False, description = "driver goal" } ]
                        , navigator = [ { complete = False, description = "navigator goal" } ]
                        , researcher = [ { complete = False, description = "researcher goal" } ]
                        , sponsor = [ { complete = True, description = "sponsor goal" } ]
                        }

                    withCompleted =
                        rpgData
                            |> Mobster.Operation.completeGoalInRpgData Sponsor 0
                in
                    Expect.equal withCompleted expectedRpgData
        ]
