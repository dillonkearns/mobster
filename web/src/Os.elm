module Os exposing (Os(..), fromString)


type Os
    = Mac
    | Windows
    | Linux
    | Other


fromString : String -> Os
fromString osString =
    let
        normalizedOs =
            osString |> String.toLower
    in
    if normalizedOs |> String.startsWith "mac" then
        Mac
    else if normalizedOs |> String.contains "win" then
        Windows
    else if normalizedOs |> String.contains "linux" then
        Linux
    else
        Other
