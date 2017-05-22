module Mobster.Data exposing (Mobster, MobsterData, containsName, currentMobsterNames, decode, decoder, empty, encoder, nextIndex, previousIndex, randomizeMobsters)

import Basics.Extra exposing ((=>))
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline exposing (hardcoded, optional, required)
import Json.Encode as Encode
import Mobster.Rpg as Rpg exposing (RpgData)
import Random
import Random.List


type alias Mobster =
    { name : String
    , rpgData : RpgData
    }


type alias MobsterData =
    { mobsters : List Mobster
    , inactiveMobsters : List Mobster
    , nextDriver : Int
    }


encoder : MobsterData -> Encode.Value
encoder mobsterData =
    Encode.object
        [ "mobsters" => Encode.list (List.map encodeMobster mobsterData.mobsters)
        , "inactiveMobsters" => Encode.list (List.map encodeMobster mobsterData.inactiveMobsters)
        , "nextDriver" => Encode.int mobsterData.nextDriver
        ]


encodeMobster : Mobster -> Encode.Value
encodeMobster mobster =
    Encode.string mobster.name


empty : MobsterData
empty =
    { mobsters = [], inactiveMobsters = [], nextDriver = 0 }


decoder : Decoder MobsterData
decoder =
    Pipeline.decode MobsterData
        |> required "mobsters" (Decode.list Decode.string |> Decode.map mobsterNamesToMobsters)
        |> optional "inactiveMobsters" (Decode.list Decode.string |> Decode.map mobsterNamesToMobsters) []
        |> required "nextDriver" Decode.int


mobsterNamesToMobsters : List String -> List Mobster
mobsterNamesToMobsters mobsterNames =
    List.map stringToMobster mobsterNames


stringToMobster : String -> Mobster
stringToMobster name =
    Mobster name Rpg.init


decode : Encode.Value -> Result String MobsterData
decode data =
    Decode.decodeValue decoder data


randomizeMobsters : MobsterData -> Random.Generator (List Mobster)
randomizeMobsters mobsterData =
    Random.List.shuffle mobsterData.mobsters


currentMobsterNames : MobsterData -> String
currentMobsterNames mobsterData =
    mobsterData.mobsters
        |> List.map .name
        |> String.join ", "


nameExists : String -> List Mobster -> Bool
nameExists mobster list =
    list
        |> List.map .name
        |> List.map (\mobsterName -> String.toLower mobsterName)
        |> List.member (String.toLower mobster)


containsName : String -> MobsterData -> Bool
containsName string mobsterData =
    nameExists string mobsterData.mobsters || nameExists string mobsterData.inactiveMobsters


previousIndex : Int -> MobsterData -> Int
previousIndex currentIndex mobsterData =
    let
        mobSize =
            List.length mobsterData.mobsters

        index =
            if mobSize == 0 then
                0
            else
                (currentIndex - 1) % mobSize
    in
    index


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
