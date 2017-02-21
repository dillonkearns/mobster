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
        [ body [ fontSize (px 15) ]
        , class BufferTop
            [ Css.marginTop (px 20) ]
        , class BufferRight
            [ marginRight (px 10)
            ]
        ]
