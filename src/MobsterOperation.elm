module MobsterOperation exposing (..)

import Mobster exposing (..)
import Array
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Json.Decode.Pipeline as Pipeline exposing (required, optional, hardcoded)
import Random.List
import Random
import ListHelpers exposing (..)


type MobsterOperation
    = Move Int Int
    | Remove Int
    | SetNextDriver Int
    | SkipTurn
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

        SkipTurn ->
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
