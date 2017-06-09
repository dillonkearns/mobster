module Roster.RpgPresenter exposing (..)

import Roster.Data exposing (RosterData)
import Roster.Rpg exposing (Experience, badges)
import Roster.RpgRole exposing (..)


type alias RpgMobster =
    { role : RpgRole
    , experience : Experience
    , name : String
    , index : Int
    }


present : RosterData -> List RpgMobster
present rosterData =
    let
        mobstersWithIndex =
            List.indexedMap (,) rosterData.mobsters
    in
    if List.length rosterData.mobsters >= 4 then
        mobstersWithIndex
            ++ mobstersWithIndex
            |> List.drop rosterData.nextDriver
            |> List.take 4
            |> List.indexedMap toRpgMobster
    else
        mobstersWithIndex
            |> List.take 4
            |> List.indexedMap toRpgMobster


experienceForRole : RpgRole -> Roster.Rpg.RpgData -> Roster.Rpg.Experience
experienceForRole role rpgData =
    case role of
        Driver ->
            rpgData.driver

        Navigator ->
            rpgData.navigator

        Mobber ->
            rpgData.mobber

        Researcher ->
            rpgData.researcher

        Sponsor ->
            rpgData.sponsor


toRpgMobster roleIndex ( mobsterIndex, mobster ) =
    let
        badgeCount =
            List.length (badges mobster.rpgData)

        level =
            if badgeCount < 1 then
                Level1
            else
                Level2
    in
    RpgMobster (getRoleForIndex level roleIndex) (experienceForRole (getRoleForIndex level roleIndex) mobster.rpgData) mobster.name mobsterIndex


getRoleForIndex : Level -> Int -> RpgRole
getRoleForIndex level index =
    case index of
        0 ->
            Driver

        1 ->
            Navigator

        n ->
            case level of
                Level1 ->
                    Mobber

                Level2 ->
                    if index == 2 then
                        Researcher
                    else
                        Sponsor
