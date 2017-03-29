module Setup.Shortcuts exposing (..)

import Array
import Basics.Extra exposing ((=>))
import Html exposing (..)
import Html.Attributes exposing (style)


letters : Array.Array String
letters =
    Array.fromList [ "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p" ]


hint : Int -> Html msg
hint index =
    let
        letter =
            Maybe.withDefault "?" (Array.get index letters)
    in
        span [ style [ "font-size" => "0.7em" ] ] [ text (" (" ++ letter ++ ")") ]
