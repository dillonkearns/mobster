module Mobster.Data exposing (MobsterData, empty, nextDriverNavigator, Role(..), mobsters, Mobster, decode, MobsterWithRole, randomizeMobsters, decoder, currentMobsterNames, containsName, nextIndex)

import Array
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Json.Decode.Pipeline as Pipeline exposing (required, optional, hardcoded)
import Random.List
import Random


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


empty : MobsterData
empty =
    { mobsters = [], inactiveMobsters = [], nextDriver = 0 }


nameExists : String -> List String -> Bool
nameExists mobster list =
    list
        |> List.map (\mobsterName -> String.toLower mobsterName)
        |> List.member (String.toLower mobster)


containsName : String -> MobsterData -> Bool
containsName string mobsterData =
    nameExists string mobsterData.mobsters
        || nameExists string mobsterData.inactiveMobsters


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
