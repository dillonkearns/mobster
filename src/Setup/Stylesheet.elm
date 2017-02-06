module Setup.Stylesheet exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)


type CssClasses
    = BufferTop
    | BufferRight


css : Stylesheet
css =
    (stylesheet << namespace "setup")
        [ class BufferTop
            [ Css.marginTop (px 20) ]
        , class BufferRight
            [ marginRight (px 10)
            ]
        ]
