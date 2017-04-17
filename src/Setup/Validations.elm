module Setup.Validations exposing (parseInputFieldWithinRange, parseIntWithinRange, inputRangeFor)

import Setup.InputField exposing (IntInputField(..))


parseInputFieldWithinRange : IntInputField -> String -> Int
parseInputFieldWithinRange intInputField rawInput =
    parseIntWithinRange (inputRangeFor intInputField) rawInput


parseIntWithinRange : ( Int, Int ) -> String -> Int
parseIntWithinRange ( min, max ) rawInput =
    let
        default =
            min
    in
        rawInput
            |> String.toInt
            |> Result.withDefault default
            |> clamp min max


inputRangeFor : IntInputField -> ( Int, Int )
inputRangeFor inputField =
    case inputField of
        BreakInterval ->
            ( 0, 120 )

        TimerDuration ->
            ( 1, 120 )

        BreakDuration ->
            ( 1, 240 )
