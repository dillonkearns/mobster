module MobsterOperation exposing (MobsterOperation(..), updateMoblist, add)

import Mobster exposing (..)
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
updateMoblist moblistOperation moblist =
    case moblistOperation of
        Move fromIndex toIndex ->
            let
                updatedMobsters =
                    move fromIndex toIndex moblist.mobsters
            in
                { moblist | mobsters = updatedMobsters }

        Remove mobsterIndex ->
            remove mobsterIndex moblist

        SetNextDriver index ->
            setNextDriver index moblist

        NextTurn ->
            setNextDriver (nextIndex moblist.nextDriver moblist) moblist

        Bench mobsterIndex ->
            bench mobsterIndex moblist

        RotateIn mobsterIndex ->
            rotateIn mobsterIndex moblist

        Add mobsterName ->
            add mobsterName moblist

        Reorder reorderedMobsters ->
            reorder reorderedMobsters moblist


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
