module Mobster.Data exposing (MobsterData, empty, decode, randomizeMobsters, decoder, currentMobsterNames, containsName, nextIndex)

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


empty : MobsterData
empty =
    { mobsters = [], inactiveMobsters = [], nextDriver = 0 }


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


nameExists : String -> List String -> Bool
nameExists mobster list =
    list
        |> List.map (\mobsterName -> String.toLower mobsterName)
        |> List.member (String.toLower mobster)


containsName : String -> MobsterData -> Bool
containsName string mobsterData =
    nameExists string mobsterData.mobsters
        || nameExists string mobsterData.inactiveMobsters


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
