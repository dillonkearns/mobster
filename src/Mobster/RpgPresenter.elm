module Mobster.RpgPresenter exposing (..)

import Mobster.Data exposing (MobsterData)
import Mobster.Rpg exposing (Experience)


type RpgRole
    = Driver
    | Navigator
    | Researcher
    | Sponsor


type alias RpgMobster =
    { role : RpgRole
    , experience : Experience
    , name : String
    , index : Int
    }


present : MobsterData -> List RpgMobster
present mobsterData =
    if List.length mobsterData.mobsters >= 4 then
        mobsterData.mobsters
            ++ mobsterData.mobsters
            |> List.drop mobsterData.nextDriver
            |> List.take 4
            |> List.indexedMap toRpgMobster
    else
        mobsterData.mobsters
            |> List.take 4
            |> List.indexedMap toRpgMobster


experienceForRole : RpgRole -> Mobster.Rpg.RpgData -> Mobster.Rpg.Experience
experienceForRole role rpgData =
    case role of
        Driver ->
            rpgData.driver

        Navigator ->
            rpgData.navigator

        Researcher ->
            rpgData.researcher

        Sponsor ->
            rpgData.sponsor


toRpgMobster index mobster =
    RpgMobster (getRoleForIndex index) (experienceForRole (getRoleForIndex index) mobster.rpgData) mobster.name index


getRoleForIndex index =
    case index of
        0 ->
            Driver

        1 ->
            Navigator

        2 ->
            Researcher

        3 ->
            Sponsor

        _ ->
            Sponsor
