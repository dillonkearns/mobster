module Setup.Stylesheet exposing (..)

import Css exposing (..)
import Css.Elements exposing (body, html)
import Css.Namespace exposing (namespace)


type CssClasses
    = BufferTop
    | BufferRight


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
        ]
