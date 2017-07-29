module Setup.Settings exposing (..)

import Basics.Extra exposing ((=>))
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (..)
import Json.Encode as Encode
import Roster.Data exposing (RosterData)


type alias Data =
    { timerDuration : Int
    , breakDuration : Int
    , intervalsPerBreak : Int
    , rosterData : RosterData
    , showHideShortcut : String
    }


decoder : Decode.Decoder Data
decoder =
    Json.Decode.Pipeline.decode Data
        |> required "timerDuration" Decode.int
        |> required "breakDuration" Decode.int
        |> required "intervalsPerBreak" Decode.int
        |> required "mobsterData" Roster.Data.decoder
        |> required "showHideShortcut" Decode.string


decode : Encode.Value -> Result String Data
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
