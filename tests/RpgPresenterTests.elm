module RpgPresenterTests exposing (all)

import Test exposing (..)
import Expect
import Mobster.RpgPresenter as RpgPresenter
import Mobster.Data as MobsterData exposing (empty)
import Mobster.Rpg as Rpg exposing (init)
import TestHelpers exposing (toMobstersNoExperience)
import Mobster.Rpg as Rpg
import Mobster.Data as MobsterData


all : Test
all =
    describe "rpg presenter"
        [ withoutExperience
        , withExperience
        ]


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
                { empty | mobsters = [ "Spock" ] |> toMobstersNoExperience }
                    |> RpgPresenter.present
                    |> Expect.equal [ RpgPresenter.RpgMobster RpgPresenter.Driver [] "Spock" 0 ]
        , test "two mobsters in list" <|
            \() ->
                { empty | mobsters = [ "Sulu", "Kirk" ] |> toMobstersNoExperience }
                    |> RpgPresenter.present
                    |> Expect.equal
                        [ RpgPresenter.RpgMobster RpgPresenter.Driver [] "Sulu" 0
                        , RpgPresenter.RpgMobster RpgPresenter.Navigator [] "Kirk" 1
                        ]
        , test "takes the first four mobsters in list" <|
            \() ->
                { empty | mobsters = [ "Sulu", "Kirk", "Spock", "Uhura", "McCoy" ] |> toMobstersNoExperience }
                    |> RpgPresenter.present
                    |> Expect.equal
                        [ RpgPresenter.RpgMobster RpgPresenter.Driver [] "Sulu" 0
                        , RpgPresenter.RpgMobster RpgPresenter.Navigator [] "Kirk" 1
                        , RpgPresenter.RpgMobster RpgPresenter.Researcher [] "Spock" 2
                        , RpgPresenter.RpgMobster RpgPresenter.Sponsor [] "Uhura" 3
                        ]
        , test "wraps around" <|
            \() ->
                { empty | nextDriver = 3, mobsters = [ "Sulu", "Kirk", "Spock", "Uhura", "McCoy" ] |> toMobstersNoExperience }
                    |> RpgPresenter.present
                    |> Expect.equal
                        [ RpgPresenter.RpgMobster RpgPresenter.Driver [] "Uhura" 0
                        , RpgPresenter.RpgMobster RpgPresenter.Navigator [] "McCoy" 1
                        , RpgPresenter.RpgMobster RpgPresenter.Researcher [] "Sulu" 2
                        , RpgPresenter.RpgMobster RpgPresenter.Sponsor [] "Kirk" 3
                        ]
        ]


withExperience : Test
withExperience =
    describe "with experience"
        [ test "one mobster in list" <|
            \() ->
                let
                    driverGoals =
                        [ { complete = True, description = "Do something" } ]

                    rpgData =
                        { init | driver = driverGoals }
                in
                    { empty | mobsters = [ MobsterData.Mobster "Sulu" rpgData ] }
                        |> RpgPresenter.present
                        |> Expect.equal
                            [ RpgPresenter.RpgMobster RpgPresenter.Driver driverGoals "Sulu" 0 ]
        , test "takes the experience from the proper roles" <|
            \() ->
                let
                    fakeExperience =
                        { driver = [ { complete = False, description = "driver goal" } ]
                        , navigator = [ { complete = False, description = "navigator goal" } ]
                        , researcher = [ { complete = False, description = "researcher goal" } ]
                        , sponsor = [ { complete = False, description = "sponsor goal" } ]
                        }

                    rpgData =
                        { init | driver = [] }
                in
                    { empty
                        | mobsters =
                            [ MobsterData.Mobster "Sulu" fakeExperience
                            , MobsterData.Mobster "Kirk" fakeExperience
                            , MobsterData.Mobster "Spock" fakeExperience
                            , MobsterData.Mobster "Uhura" fakeExperience
                            , MobsterData.Mobster "Bones" fakeExperience
                            ]
                    }
                        |> RpgPresenter.present
                        |> Expect.equal
                            [ RpgPresenter.RpgMobster RpgPresenter.Driver fakeExperience.driver "Sulu" 0
                            , RpgPresenter.RpgMobster RpgPresenter.Navigator fakeExperience.navigator "Kirk" 1
                            , RpgPresenter.RpgMobster RpgPresenter.Researcher fakeExperience.researcher "Spock" 2
                            , RpgPresenter.RpgMobster RpgPresenter.Sponsor fakeExperience.sponsor "Uhura" 3
                            ]
        ]
