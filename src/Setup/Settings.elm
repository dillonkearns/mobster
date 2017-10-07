module Setup.Settings exposing (Data, decode, decoder, encoder, initial)

import Basics.Extra exposing ((=>))
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Json.Encode as Encode
import Roster.Data exposing (RosterData)


type alias Data =
    { timerDuration : Int
    , breakDuration : Int
    , intervalsPerBreak : Int
    , rosterData : RosterData
    , showHideShortcut : String
    }


decoder : Decode.Decoder (Maybe Data)
decoder =
    Decode.nullable settingsDecoder


settingsDecoder : Decode.Decoder Data
settingsDecoder =
    Pipeline.decode Data
        |> Pipeline.required "timerDuration" Decode.int
        |> Pipeline.required "breakDuration" Decode.int
        |> Pipeline.required "intervalsPerBreak" Decode.int
        |> Pipeline.required "mobsterData" Roster.Data.decoder
        |> Pipeline.required "showHideShortcut" Decode.string


decode : Encode.Value -> Result String (Maybe Data)
decode data =
    Decode.decodeValue decoder data


encoder : Data -> Encode.Value
encoder settingsData =
    Encode.object
        [ "timerDuration" => Encode.int settingsData.timerDuration
        , "breakDuration" => Encode.int settingsData.breakDuration
        , "intervalsPerBreak" => Encode.int settingsData.intervalsPerBreak
        , "mobsterData" => Roster.Data.encoder settingsData.rosterData
        , "showHideShortcut" => Encode.string settingsData.showHideShortcut
        ]


initial : Data
initial =
    { timerDuration = 5
    , breakDuration = 5
    , intervalsPerBreak = 5
    , rosterData = Roster.Data.empty
    , showHideShortcut = "L"
    }
