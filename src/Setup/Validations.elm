module Setup.Validations exposing (..)


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
