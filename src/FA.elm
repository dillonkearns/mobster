module FA exposing (Icon(..), iconClass)


type Icon
    = Gamepad
    | Github


iconClass : Icon -> String
iconClass icon =
    "fa fa-" ++ iconString icon


iconString : Icon -> String
iconString icon =
    case icon of
        Github ->
            "github-alt"

        plainIconName ->
            plainIconName
                |> toString
                |> String.toLower
