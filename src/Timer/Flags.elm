module Timer.Flags exposing (IncomingFlags, decoder, encodeBreak, encodeRegularTimer)

import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
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
        [ ( "minutes", Encode.int flags.minutes )
        , ( "driver", Encode.string flags.driver )
        , ( "navigator", Encode.string flags.navigator )
        , ( "isBreak", Encode.bool False )
        ]


encodeBreak : Int -> Encode.Value
encodeBreak breakDurationMinutes =
    Encode.object
        [ ( "minutes", Encode.int breakDurationMinutes )
        , ( "isBreak", Encode.bool True )
        ]


decoder : Decode.Decoder IncomingFlags
decoder =
    Decode.succeed IncomingFlags
        |> Pipeline.required "minutes" Decode.int
        |> Pipeline.optional "driver" Decode.string ""
        |> Pipeline.optional "navigator" Decode.string ""
        |> Pipeline.required "isBreak" Decode.bool
        |> Pipeline.optional "isDev" Decode.bool False
