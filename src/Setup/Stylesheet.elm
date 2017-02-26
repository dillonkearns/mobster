module Setup.Stylesheet exposing (..)

import Css exposing (..)
import Css.Elements exposing (body, html, span)
import Css.Namespace exposing (namespace)


-- import Css.Colors as Colors


type CssClasses
    = BufferTop
    | BufferRight
    | Green
    | Orange
    | Red
    | DropAreaInactive
    | DropAreaActive


css : Stylesheet
css =
    (stylesheet << namespace "setup")
        [ mediaQuery "screen and ( max-width: 800px )"
            [ body
                [ fontSize (px 7) ]
            ]
        , mediaQuery "screen and ( min-width: 801px ) and ( max-width: 1000px )"
            [ body
                [ fontSize (px 10) ]
            ]
        , mediaQuery "screen and ( min-width: 1001px )"
            [ body
                [ fontSize (px 15) ]
            ]
        , class BufferTop
            [ Css.marginTop (px 20) ]
        , class BufferRight
            [ marginRight (px 10)
            ]
        , class Green (hoverButton (rgba 50 250 50 0.6))
        , class Red (hoverButton (rgba 231 76 60 0.7))
        , class Orange (hoverButton (rgba 255 133 27 1))
        , class DropAreaInactive [ backgroundColor (rgba 150 150 100 0.7), borderStyle Css.dotted ]
        , class DropAreaActive [ backgroundColor (rgba 250 150 100 0.5), borderStyle Css.dotted ]
        ]


hoverButton : ColorValue compatible -> List Mixin
hoverButton customColor =
    [ hover
        [ children
            [ span [ color customColor ]
            , selector "u" [ color customColor ]
            ]
        ]
    ]
