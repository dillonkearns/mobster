module Timer.Flags exposing (..)

import Json.Encode as Encode
import Basics.Extra exposing ((=>))
import Json.Decode
import Json.Decode.Pipeline as Pipeline exposing (required, optional, hardcoded)


type alias Flags =
    { minutes : Int
    , driver : String
    , navigator : String
    , isBreak : Bool
    }


type alias IncomingFlags =
    { minutes : Int
    , driver : String
    , navigator : String
    , isBreak : Bool
    , isDev : Bool
    }


encode : Flags -> Encode.Value
encode flags =
    Encode.object
        [ "minutes" => Encode.int flags.minutes
        , "driver" => Encode.string flags.driver
        , "navigator" => Encode.string flags.navigator
        , "isBreak" => Encode.bool flags.isBreak
        ]


decoder : Json.Decode.Decoder IncomingFlags
decoder =
    Pipeline.decode IncomingFlags
        |> required "minutes" (Json.Decode.int)
        |> required "driver" (Json.Decode.string)
        |> required "navigator" (Json.Decode.string)
        |> required "isBreak" (Json.Decode.bool)
        |> optional "isDev" (Json.Decode.bool) False
