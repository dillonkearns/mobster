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
        |> optional "breakDuration" Decode.int 5
        |> required "intervalsPerBreak" Decode.int
        |> required "rosterData" Roster.Data.decoder
        |> optional "showHideShortcut" Decode.string "K"


decode : Encode.Value -> Result String Data
decode data =
    Decode.decodeValue decoder data


encoder : Data -> Encode.Value
encoder settingsData =
    Encode.object
        [ "timerDuration" => Encode.int settingsData.timerDuration
        , "breakDuration" => Encode.int settingsData.breakDuration
        , "intervalsPerBreak" => Encode.int settingsData.intervalsPerBreak
        , "rosterData" => Roster.Data.encoder settingsData.rosterData
        , "showHideShortcut" => Encode.string settingsData.showHideShortcut
        ]


initial : Data
initial =
    { timerDuration = 5
    , breakDuration = 5
    , intervalsPerBreak = 5
    , rosterData = Roster.Data.empty
    , showHideShortcut = "K"
    }
