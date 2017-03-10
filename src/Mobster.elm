module Mobster exposing (MobsterOperation(..), MobsterData, updateMoblist, empty, nextDriverNavigator, Role(..), mobsters, Mobster, add, rotate, decode, MobsterWithRole, randomizeMobsters, reorder, decoder, currentMobsterNames)

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


type alias MobsterData =
    { mobsters : List String
    , inactiveMobsters : List String
    , nextDriver : Int
    }


decoder : Decoder MobsterData
decoder =
    Pipeline.decode MobsterData
        |> required "mobsters" (Decode.list Decode.string)
        |> optional "inactiveMobsters" (Decode.list Decode.string) []
        |> required "nextDriver" (Decode.int)


decode : Encode.Value -> Result String MobsterData
decode data =
    Decode.decodeValue decoder data


randomizeMobsters : MobsterData -> Random.Generator (List String)
randomizeMobsters mobsterData =
    Random.List.shuffle mobsterData.mobsters


currentMobsterNames : MobsterData -> String
currentMobsterNames mobsterData =
    String.join ", " mobsterData.mobsters


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


reorder : List String -> MobsterData -> MobsterData
reorder shuffledMobsters mobsterData =
    { mobsterData | mobsters = shuffledMobsters, nextDriver = 0 }


empty : MobsterData
empty =
    { mobsters = [], inactiveMobsters = [], nextDriver = 0 }


add : String -> MobsterData -> MobsterData
add mobster list =
    { list | mobsters = (List.append list.mobsters [ mobster ]) }


type alias DriverNavigator =
    { driver : Mobster
    , navigator : Mobster
    }


nextDriverNavigator : MobsterData -> DriverNavigator
nextDriverNavigator mobsterData =
    let
        list =
            asMobsterList mobsterData

        mobstersAsArray =
            Array.fromList list

        maybeDriver =
            Array.get mobsterData.nextDriver mobstersAsArray

        driver =
            case maybeDriver of
                Just justDriver ->
                    justDriver

                Nothing ->
                    { name = "", index = -1 }

        navigatorIndex =
            nextIndex mobsterData.nextDriver mobsterData

        maybeNavigator =
            Array.get navigatorIndex mobstersAsArray

        navigator =
            case maybeNavigator of
                Just justNavigator ->
                    justNavigator

                Nothing ->
                    driver
    in
        { driver = driver
        , navigator = navigator
        }


nextIndex : Int -> MobsterData -> Int
nextIndex currentIndex mobsterData =
    let
        mobSize =
            List.length mobsterData.mobsters

        index =
            if mobSize == 0 then
                0
            else
                (currentIndex + 1) % mobSize
    in
        index


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


rotate : MobsterData -> MobsterData
rotate mobsterData =
    { mobsterData | nextDriver = (nextIndex mobsterData.nextDriver mobsterData) }


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
                        List.append list.mobsters [ mobsterToMove ]
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


type Role
    = Driver
    | Navigator


type alias Mobster =
    { name : String, index : Int }


type alias MobsterWithRole =
    { name : String, role : Maybe Role, index : Int }


type alias Mobsters =
    List MobsterWithRole


mobsterListItemToMobster : DriverNavigator -> Int -> String -> MobsterWithRole
mobsterListItemToMobster driverNavigator index mobsterName =
    let
        role =
            if index == driverNavigator.driver.index then
                Just Driver
            else if index == driverNavigator.navigator.index then
                Just Navigator
            else
                Nothing
    in
        { name = mobsterName, role = role, index = index }


asMobsterList : MobsterData -> List Mobster
asMobsterList mobsterData =
    List.indexedMap (\index mobsterName -> { name = mobsterName, index = index }) mobsterData.mobsters


mobsters : MobsterData -> Mobsters
mobsters mobsterData =
    List.indexedMap (mobsterListItemToMobster (nextDriverNavigator mobsterData)) mobsterData.mobsters


setNextDriver : Int -> MobsterData -> MobsterData
setNextDriver newDriver mobsterData =
    { mobsterData | nextDriver = newDriver }
