module Mobster.Operation exposing (MobsterOperation(..), updateMoblist, add, completeGoalInRpgData)

import Array
import ListHelpers exposing (..)
import Mobster.Data exposing (Mobster, MobsterData, nextIndex)
import Mobster.Rpg as Rpg exposing (RpgData)
import Mobster.RpgRole exposing (..)


type MobsterOperation
    = Move Int Int
    | Remove Int
    | SetNextDriver Int
    | NextTurn
    | Bench Int
    | RotateIn Int
    | Add String
    | Reorder (List Mobster)
    | CompleteGoal Int RpgRole Int


updateMoblist : MobsterOperation -> MobsterData -> MobsterData
updateMoblist mobsterOperation mobsterData =
    case mobsterOperation of
        Move fromIndex toIndex ->
            let
                updatedMobsters =
                    move fromIndex toIndex mobsterData.mobsters
            in
                { mobsterData | mobsters = updatedMobsters }

        Remove mobsterIndex ->
            remove mobsterIndex mobsterData

        SetNextDriver index ->
            setNextDriver index mobsterData

        NextTurn ->
            setNextDriver (nextIndex mobsterData.nextDriver mobsterData) mobsterData

        Bench mobsterIndex ->
            bench mobsterIndex mobsterData

        RotateIn mobsterIndex ->
            rotateIn mobsterIndex mobsterData

        Add mobsterName ->
            add mobsterName mobsterData

        Reorder reorderedMobsters ->
            reorder reorderedMobsters mobsterData

        CompleteGoal mobsterIndex role goalIndex ->
            mobsterData
                |> completeGoal mobsterIndex role goalIndex


mobsterWithCompletedGoal : Int -> RpgRole -> Int -> List Mobster -> Maybe Mobster
mobsterWithCompletedGoal mobsterIndex role goalIndex mobsterData =
    let
        maybeMobster =
            mobsterData
                |> Array.fromList
                |> Array.get mobsterIndex
    in
        case maybeMobster of
            Just mobster ->
                let
                    updatedRpgData =
                        completeGoalInRpgData role goalIndex mobster.rpgData
                in
                    Just { mobster | rpgData = updatedRpgData }

            Nothing ->
                Nothing


completeGoal : Int -> RpgRole -> Int -> Mobster.Data.MobsterData -> MobsterData
completeGoal mobsterIndex role goalIndex mobsterData =
    let
        withGoal =
            mobsterWithCompletedGoal mobsterIndex role goalIndex mobsterData.mobsters

        updatedMobsters =
            case withGoal of
                Just mobsterWithGoal ->
                    mobsterData.mobsters
                        |> Array.fromList
                        |> Array.set mobsterIndex mobsterWithGoal
                        |> Array.toList

                Nothing ->
                    mobsterData.mobsters
    in
        { mobsterData | mobsters = updatedMobsters }


add : String -> MobsterData -> MobsterData
add mobster list =
    { list | mobsters = (List.append list.mobsters [ { name = mobster, rpgData = Rpg.init } ]) }


rotateIn : Int -> MobsterData -> MobsterData
rotateIn index list =
    let
        ( maybeMobsterToMove, inactiveWithoutNewlyActive ) =
            removeAndGet index list.inactiveMobsters
    in
        case maybeMobsterToMove of
            Just mobsterToMove ->
                let
                    activeWithNewlyActive =
                        list.mobsters
                            |> Array.fromList
                            |> insertAt mobsterToMove list.nextDriver False
                            |> Array.toList
                in
                    { list | mobsters = activeWithNewlyActive, inactiveMobsters = inactiveWithoutNewlyActive }

            Nothing ->
                list


bench : Int -> MobsterData -> MobsterData
bench index list =
    let
        ( maybeMobsterToBench, activeWithoutBenchedMobster ) =
            removeAndGet index list.mobsters
    in
        case maybeMobsterToBench of
            Just mobsterToBench ->
                let
                    updatedInactive =
                        List.append list.inactiveMobsters [ mobsterToBench ]
                in
                    { list
                        | mobsters = activeWithoutBenchedMobster
                        , inactiveMobsters = updatedInactive
                    }
                        |> setNextDriverInBounds

            Nothing ->
                list


remove : Int -> MobsterData -> MobsterData
remove index list =
    { list | inactiveMobsters = removeFromListAt index list.inactiveMobsters }


setNextDriver : Int -> MobsterData -> MobsterData
setNextDriver newDriver mobsterData =
    { mobsterData | nextDriver = newDriver }


reorder : List Mobster.Data.Mobster -> MobsterData -> MobsterData
reorder shuffledMobsters mobsterData =
    { mobsterData | mobsters = shuffledMobsters, nextDriver = 0 }


setNextDriverInBounds : MobsterData -> MobsterData
setNextDriverInBounds mobsterData =
    let
        maxDriverIndex =
            (List.length mobsterData.mobsters) - 1

        indexInBounds =
            if mobsterData.nextDriver > maxDriverIndex && mobsterData.nextDriver > 0 then
                0
            else
                mobsterData.nextDriver
    in
        { mobsterData | nextDriver = indexInBounds }


completeGoalInRpgData : RpgRole -> Int -> RpgData -> RpgData
completeGoalInRpgData role goalIndex rpgData =
    let
        experience =
            case role of
                Driver ->
                    rpgData.driver

                Navigator ->
                    rpgData.navigator

                Researcher ->
                    rpgData.researcher

                Sponsor ->
                    rpgData.sponsor

        goal =
            goalFromIndex goalIndex experience

        updatedExperience =
            experience
                |> Array.fromList
                |> Array.set goalIndex (completeGoal2 goal)
                |> Array.toList

        updatedRpgData =
            case role of
                Driver ->
                    { rpgData | driver = updatedExperience }

                Navigator ->
                    { rpgData | navigator = updatedExperience }

                Researcher ->
                    { rpgData | researcher = updatedExperience }

                Sponsor ->
                    { rpgData | sponsor = updatedExperience }
    in
        updatedRpgData


completeGoal2 goal =
    { goal | complete = True }


goalFromIndex goalIndex experience =
    experience
        |> Array.fromList
        |> Array.get goalIndex
        |> Maybe.withDefault { description = "", complete = True }


updateMobsterGoal : Int -> Mobster -> Mobster
updateMobsterGoal goalIndex mobster =
    let
        goal =
            mobster.rpgData.driver
                |> Array.fromList
                |> Array.get goalIndex
                |> Maybe.withDefault { description = "", complete = True }

        completeGoal =
            { goal | complete = True }

        updatedExperience =
            mobster.rpgData.driver
                |> Array.fromList
                |> Array.set goalIndex completeGoal
                |> Array.toList

        rpgData =
            mobster.rpgData

        updatedRpgData =
            { rpgData | driver = updatedExperience }
    in
        { mobster | rpgData = updatedRpgData }
