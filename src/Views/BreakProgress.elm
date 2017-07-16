module Views.BreakProgress exposing (view)

import Element exposing (Device)
import Element.Attributes as Attr
import Styles exposing (StyleElement)


view : StyleElement
view =
    Element.row Styles.None
        [ Attr.spacing 1 ]
        [ circleView Styles.Filled
        , circleView Styles.Hollow
        ]


circleView : Styles.CircleFill -> StyleElement
circleView circleFill =
    Element.el (Styles.Circle circleFill) [ Attr.width (Attr.px 15), Attr.height (Attr.px 15) ] Element.empty
