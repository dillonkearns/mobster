module RpgPresenterTests exposing (all)

import Test exposing (..)
import Expect
import Mobster.RpgPresenter as RpgPresenter
import Mobster.Data as MobsterData exposing (empty)


all : Test
all =
    describe "rpg presenter"
        [ withoutExperience ]


withoutExperience : Test
withoutExperience =
    describe "without experience"
        [ test "empty mobster data" <|
            \() ->
                empty
                    |> RpgPresenter.present
                    |> Expect.equal []
        , test "single mobster in list" <|
            \() ->
                { empty | mobsters = [ "Spock" ] }
                    |> RpgPresenter.present
                    |> Expect.equal [ RpgPresenter.RpgMobster RpgPresenter.Driver [] "Spock" 0 ]
        , test "two mobsters in list" <|
            \() ->
                { empty | mobsters = [ "Sulu", "Kirk" ] }
                    |> RpgPresenter.present
                    |> Expect.equal
                        [ RpgPresenter.RpgMobster RpgPresenter.Driver [] "Sulu" 0
                        , RpgPresenter.RpgMobster RpgPresenter.Navigator [] "Kirk" 1
                        ]
        ]
