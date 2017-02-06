module Setup.Stylesheet exposing (..)

import Css exposing (..)
import Css.Elements exposing (body, li)
import Css.Namespace exposing (namespace)


css : Stylesheet
css =
    (stylesheet << namespace "setup")
        []
