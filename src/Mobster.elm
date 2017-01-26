module Mobster exposing (MoblistOperation(..), MobsterData, updateMoblist, empty, nextDriverNavigator, Role(..), mobsters, Mobster, add, rotate, decode)

import Array
import Maybe
import Array.Extra
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Json.Decode.Pipeline as Pipeline exposing (required, optional, hardcoded)


type MoblistOperation
    = MoveUp Int
    | MoveDown Int
    | Remove Int
    | SetNextDriver Int


type alias MobsterData =
    { mobsters : List String, nextDriver : Int }


decoder : Decoder MobsterData
decoder =
    Pipeline.decode MobsterData
        |> required "mobsters" (Decode.list Decode.string)
        |> required "nextDriver" (Decode.int)


decode : Encode.Value -> Result String MobsterData
decode data =
    Decode.decodeValue decoder data


updateMoblist : MoblistOperation -> MobsterData -> MobsterData
updateMoblist moblistOperation moblist =
    case moblistOperation of
        MoveUp mobsterIndex ->
            moveUp mobsterIndex moblist

        MoveDown mobsterIndex ->
            moveDown mobsterIndex moblist

        Remove mobsterIndex ->
            remove mobsterIndex moblist

        SetNextDriver index ->
            setNextDriver index moblist


empty : MobsterData
empty =
    { mobsters = [], nextDriver = 0 }


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
                    { name = "", role = Nothing, index = -1 }

        driverWithRole =
            { driver | role = Just Driver }

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

        navigatorWithRole =
            { navigator | role = Just Navigator }
    in
        { driver = driverWithRole
        , navigator = navigatorWithRole
        }


nextIndex : Int -> MobsterData -> Int
nextIndex currentIndex mobsterList =
    let
        mobSize =
            List.length mobsterList.mobsters

        index =
            if mobSize == 0 then
                0
            else
                (currentIndex + 1) % mobSize
    in
        index


rotate : MobsterData -> MobsterData
rotate mobsterList =
    { mobsterList | nextDriver = (nextIndex mobsterList.nextDriver mobsterList) }


moveDown : Int -> MobsterData -> MobsterData
moveDown itemIndex list =
    moveUp (itemIndex + 1) list


moveUp : Int -> MobsterData -> MobsterData
moveUp itemIndex list =
    let
        asArray =
            Array.fromList list.mobsters

        maybeItemToMove =
            Array.get itemIndex asArray

        maybeNeighboringItem =
            Array.get (itemIndex - 1) asArray

        updatedMobsters =
            case ( maybeItemToMove, maybeNeighboringItem ) of
                ( Just itemToMove, Just neighboringItem ) ->
                    Array.toList
                        (asArray
                            |> Array.set itemIndex neighboringItem
                            |> Array.set (itemIndex - 1) itemToMove
                        )

                ( _, _ ) ->
                    list.mobsters
    in
        { list | mobsters = updatedMobsters }


remove : Int -> MobsterData -> MobsterData
remove index list =
    let
        asArray =
            (Array.fromList list.mobsters)

        updatedMobsters =
            Array.toList (Array.Extra.removeAt index asArray)

        maxIndex =
            ((List.length updatedMobsters) - 1)

        nextDriverInBounds =
            if list.nextDriver > maxIndex && list.nextDriver > 0 then
                0
            else
                list.nextDriver
    in
        { list | mobsters = updatedMobsters, nextDriver = nextDriverInBounds }


type Role
    = Driver
    | Navigator


type alias Mobster =
    { name : String, role : Maybe Role, index : Int }


type alias Mobsters =
    List Mobster


mobsterListItemToMobster : DriverNavigator -> Int -> String -> Mobster
mobsterListItemToMobster driverNavigator index mobsterName =
    let
        role =
            if mobsterName == driverNavigator.driver.name then
                Just Driver
            else if mobsterName == driverNavigator.navigator.name then
                Just Navigator
            else
                Nothing
    in
        { name = mobsterName, role = role, index = index }


asMobsterList : MobsterData -> List Mobster
asMobsterList mobsterData =
    List.indexedMap (\index mobsterName -> { name = mobsterName, index = index, role = Nothing }) mobsterData.mobsters
        |> List.map (\details -> { details | role = Nothing })


mobsters : MobsterData -> Mobsters
mobsters mobsterList =
    List.indexedMap (mobsterListItemToMobster (nextDriverNavigator mobsterList)) mobsterList.mobsters


setNextDriver : Int -> MobsterData -> MobsterData
setNextDriver newDriver mobsterData =
    { mobsterData | nextDriver = newDriver }
