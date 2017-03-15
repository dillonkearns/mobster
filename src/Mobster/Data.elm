module Mobster.Data exposing (MobsterData, Mobster, empty, decode, randomizeMobsters, decoder, currentMobsterNames, containsName, nextIndex)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Json.Decode.Pipeline as Pipeline exposing (required, optional, hardcoded)
import Random.List
import Random
import Mobster.Rpg exposing (RpgData)


type alias Mobster =
    { name : String
    , rpgData : RpgData
    }


type alias MobsterData =
    { mobsters : List Mobster
    , inactiveMobsters : List Mobster
    , nextDriver : Int
    }


empty : MobsterData
empty =
    { mobsters = [], inactiveMobsters = [], nextDriver = 0 }


decoder : Decoder MobsterData
decoder =
    Pipeline.decode MobsterData
        -- |> required "mobsters" (Decode.list Decode.string)
        -- |> optional "inactiveMobsters" (Decode.list Decode.string) []
        |>
            hardcoded []
        |> hardcoded []
        |> required "nextDriver" (Decode.int)


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
