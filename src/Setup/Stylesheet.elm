module Setup.Stylesheet exposing (css, helpers)

import Css exposing (..)
import Css.Elements exposing (a, body, button, html, span)
import Css.Namespace exposing (namespace)
import Html.CssHelpers
import StylesheetHelper exposing (CssClasses(..))


helpers : Html.CssHelpers.Namespace String class id msg
helpers =
    Html.CssHelpers.withNamespace "setup"


css : Stylesheet
css =
    (stylesheet << namespace "setup")
        [ button [ cursor default ]
        , class RpgIcon1 (rpgIconCss (rgb 8 133 236))
        , class RpgIcon2 (rpgIconCss (rgb 144 7 179))
        ]


rpgIconCss : ColorValue compatible -> List Mixin
rpgIconCss color =
    [ descendants [ selector "g" [ fill color ] ] ]
