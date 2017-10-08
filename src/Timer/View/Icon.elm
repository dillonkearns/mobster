module Timer.View.Icon exposing (coffeeIcon, driverIcon, navigatorIcon)

import Element exposing (Element)
import Element.Attributes
import Timer.Styles as Styles exposing (StyleElement)


coffeeIcon : StyleElement
coffeeIcon =
    Element.el Styles.BreakIcon [ Element.Attributes.class "fa fa-coffee" ] Element.empty


driverIcon : StyleElement
driverIcon =
    iconView driverIconPath


navigatorIcon : StyleElement
navigatorIcon =
    iconView navigatorIconPath


iconView : String -> StyleElement
iconView iconUrl =
    Element.image Styles.None
        [ Element.Attributes.width (Element.Attributes.px 20)
        , Element.Attributes.height (Element.Attributes.px 20)
        ]
        { src = iconUrl, caption = "icon" }


driverIconPath : String
driverIconPath =
    "../assets/driver-icon.png"


navigatorIconPath : String
navigatorIconPath =
    "../assets/navigator-icon.png"
