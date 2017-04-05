module Setup.Settings exposing (..)

import Json.Decode as Decode
import Json.Encode as Encode
import Json.Decode.Pipeline exposing (..)
import Mobster.Data exposing (MobsterData)
import Basics.Extra exposing ((=>))


type alias Data =
    { timerDuration : Int
    , breakDuration : Int
    , intervalsPerBreak : Int
    , mobsterData : MobsterData
    }


decoder : Decode.Decoder Data
decoder =
    Json.Decode.Pipeline.decode Data
        |> required "timerDuration" (Decode.int)
        |> optional "breakDuration" (Decode.int) 5
        |> required "intervalsPerBreak" (Decode.int)
        |> required "mobsterData" (Mobster.Data.decoder)


decode : Encode.Value -> Result String Data
decode data =
    Decode.decodeValue decoder data


encoder : Data -> Encode.Value
encoder settingsData =
    Encode.object
        [ "timerDuration" => Encode.int settingsData.timerDuration
        , "breakDuration" => Encode.int settingsData.breakDuration
        , "intervalsPerBreak" => Encode.int settingsData.intervalsPerBreak
        , "mobsterData" => Mobster.Data.encoder settingsData.mobsterData
        ]


initial : Data
initial =
    { timerDuration = 5
    , breakDuration = 5
    , intervalsPerBreak = 5
    , mobsterData = Mobster.Data.empty
    }
