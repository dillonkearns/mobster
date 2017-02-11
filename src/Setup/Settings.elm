module Setup.Settings exposing (..)

import Json.Decode as Decode
import Json.Encode as Encode
import Json.Decode.Pipeline exposing (..)
import Mobster


type alias Data =
    { timerDuration : Int
    , intervalsPerBreak : Int
    , mobsterData : Mobster.MobsterData
    }


decoder : Decode.Decoder Data
decoder =
    Json.Decode.Pipeline.decode Data
        |> required "timerDuration" (Decode.int)
        |> required "intervalsPerBreak" (Decode.int)
        |> required "mobsterData" (Mobster.decoder)


decode : Encode.Value -> Result String Data
decode data =
    Decode.decodeValue decoder data


initial : Data
initial =
    { timerDuration = 5
    , intervalsPerBreak = 5
    , mobsterData = Mobster.empty
    }
