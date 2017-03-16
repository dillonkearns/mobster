module Mobster.Operation exposing (MobsterOperation(..), updateMoblist, add)

import Mobster.Data exposing (nextIndex, MobsterData, Mobster)
import Array
import ListHelpers exposing (..)
import Mobster.Rpg as Rpg exposing (RpgData)
import Mobster.RpgPresenter exposing (RpgRole)


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


mobsterWithCompletedGoal : Int -> List Mobster -> Maybe Mobster
mobsterWithCompletedGoal mobsterIndex mobsterData =
    let
        maybeMobster =
            mobsterData
                |> Array.fromList
                |> Array.get mobsterIndex
    in
        case maybeMobster of
            Just mobster ->
                Just (updateMobsterGoal 0 mobster)

            Nothing ->
                Nothing


updateMobsterGoal : Int -> Mobster -> Mobster
updateMobsterGoal goalIndex mobster =
    let
        changedGoal =
            { complete = True, description = "driver goal" }

        updatedExperience =
            mobster.rpgData.driver
                |> Array.fromList
                |> Array.set goalIndex changedGoal
                |> Array.toList

        rpgData =
            mobster.rpgData

        updatedRpgData =
            { rpgData | driver = updatedExperience }
    in
        { mobster | rpgData = updatedRpgData }


completeGoal : Int -> Mobster.RpgPresenter.RpgRole -> Int -> Mobster.Data.MobsterData -> MobsterData
completeGoal mobsterIndex role goalIndex mobsterData =
    let
        withGoal =
            mobsterWithCompletedGoal mobsterIndex mobsterData.mobsters

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
