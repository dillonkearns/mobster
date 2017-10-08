module Timer.Styles exposing (StyleElement, Styles(..), styleSheet)

import Color
import Element exposing (Element)
import Style
import Style.Color
import Style.Font
import Timer.Msg exposing (Msg)


type alias StyleElement =
    Element Styles Never Msg


type Styles
    = None
    | Timer
    | MobsterName
    | BreakIcon


styleSheet : Style.StyleSheet Styles Never
styleSheet =
    Style.styleSheet
        [ Style.style None
            [ [ "Lato" ]
                |> List.map Style.Font.font
                |> Style.Font.typeface
            ]
        , Style.style Timer
            [ Style.Font.size 39
            ]
        , Style.style MobsterName
            [ Style.Font.size 15
            ]
        , Style.style BreakIcon
            [ Style.Font.size 50
            , Color.rgb 8 226 108 |> Style.Color.text
            ]
        ]
