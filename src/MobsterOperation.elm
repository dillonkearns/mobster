module MobsterOperation exposing (MobsterOperation(..), updateMoblist, add)

import Mobster exposing (nextIndex, MobsterData)
import Array
import ListHelpers exposing (..)


type MobsterOperation
    = Move Int Int
    | Remove Int
    | SetNextDriver Int
    | NextTurn
    | Bench Int
    | RotateIn Int
    | Add String
    | Reorder (List String)


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


add : String -> MobsterData -> MobsterData
add mobster list =
    { list | mobsters = (List.append list.mobsters [ mobster ]) }


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


reorder : List String -> MobsterData -> MobsterData
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
