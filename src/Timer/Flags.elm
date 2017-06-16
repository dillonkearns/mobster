module Timer.Flags exposing (..)

import Basics.Extra exposing ((=>))
import Json.Decode
import Json.Decode.Pipeline as Pipeline exposing (hardcoded, optional, required)
import Json.Encode as Encode


type alias IncomingFlags =
    { minutes : Int
    , driver : String
    , navigator : String
    , isBreak : Bool
    , isDev : Bool
    }


encodeRegularTimer :
    { outgoingFlags
        | driver : String
        , minutes : Int
        , navigator : String
    }
    -> Encode.Value
encodeRegularTimer flags =
    Encode.object
        [ "minutes" => Encode.int flags.minutes
        , "driver" => Encode.string flags.driver
        , "navigator" => Encode.string flags.navigator
        , "isBreak" => Encode.bool False
        ]


encodeBreak : Int -> Encode.Value
encodeBreak breakDurationMinutes =
    Encode.object
        [ "minutes" => Encode.int breakDurationMinutes
        , "isBreak" => Encode.bool True
        ]


decoder : Json.Decode.Decoder IncomingFlags
decoder =
    Pipeline.decode IncomingFlags
        |> required "minutes" Json.Decode.int
        |> optional "driver" Json.Decode.string ""
        |> optional "navigator" Json.Decode.string ""
        |> required "isBreak" Json.Decode.bool
        |> optional "isDev" Json.Decode.bool False
