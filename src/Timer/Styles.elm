module Timer.Styles exposing (StyleElement, Styles(..), styleSheet)

import Style.Color
import Element exposing (Element)
import Style exposing (Font)
import Style.Color
import Style.Font as Font
import Timer.Msg exposing (Msg)


type alias StyleElement =
    Element Styles Never Msg


type Styles
    = None
    | Timer
    | MobsterName
    | BreakIcon


font : List Style.Font
font =
    [ "Lato", "Helvetica Neue", "helvetica", "arial", "sans-serif" ] |> List.map Font.font


styleSheet : Style.StyleSheet Styles Never
styleSheet =
    Style.styleSheet
        [ Style.style None
            [ Font.typeface font
            ]
        , Style.style Timer
            [ Font.size 39
            ]
        , Style.style MobsterName
            [ Font.size 15
            ]
        , Style.style BreakIcon
            [ Font.size 50
            , Color.rgb 8 226 108 |> Style.Color.text
            ]
        ]
