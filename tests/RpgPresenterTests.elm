module RpgPresenterTests exposing (all)

import Test exposing (..)
import Expect
import Mobster.RpgPresenter as RpgPresenter
import Mobster.Data as MobsterData exposing (empty)
import TestHelpers exposing (toMobsters)


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
                { empty | mobsters = [ "Spock" ] |> toMobsters }
                    |> RpgPresenter.present
                    |> Expect.equal [ RpgPresenter.RpgMobster RpgPresenter.Driver [] "Spock" 0 ]
        , test "two mobsters in list" <|
            \() ->
                { empty | mobsters = [ "Sulu", "Kirk" ] |> toMobsters }
                    |> RpgPresenter.present
                    |> Expect.equal
                        [ RpgPresenter.RpgMobster RpgPresenter.Driver [] "Sulu" 0
                        , RpgPresenter.RpgMobster RpgPresenter.Navigator [] "Kirk" 1
                        ]
        , test "four mobsters in list" <|
            \() ->
                { empty | mobsters = [ "Sulu", "Kirk", "Spock", "Uhura", "McCoy" ] |> toMobsters }
                    |> RpgPresenter.present
                    |> Expect.equal
                        [ RpgPresenter.RpgMobster RpgPresenter.Driver [] "Sulu" 0
                        , RpgPresenter.RpgMobster RpgPresenter.Navigator [] "Kirk" 1
                        , RpgPresenter.RpgMobster RpgPresenter.Researcher [] "Spock" 2
                        , RpgPresenter.RpgMobster RpgPresenter.Sponsor [] "Uhura" 3
                        ]
        ]
