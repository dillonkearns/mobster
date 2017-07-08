module TimerFlagsTests exposing (suite)

import Expect
import Json.Decode as Decode
import Test exposing (..)
import Timer.Flags


suite : Test
suite =
    test "decoder parses same object as the encoder generates" <|
        \() ->
            let
                flags =
                    { minutes = 123, driver = "Sulu", navigator = "Kirk", isBreak = False }
            in
            flags
                |> Timer.Flags.encodeRegularTimer
                |> Decode.decodeValue Timer.Flags.decoder
                |> Expect.equal
                    (Ok
                        { minutes = 123, driver = "Sulu", navigator = "Kirk", isBreak = False, isDev = False }
                    )
