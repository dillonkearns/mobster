module Setup.Stylesheet exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)


type CssClasses
    = BufferTop


css : Stylesheet
css =
    (stylesheet << namespace "setup")
        [ class BufferTop
            [ Css.marginTop (px 20) ]
        ]
