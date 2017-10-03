module Responsive exposing (Palette, defaultPalette, palette)

import Element exposing (Device)
import Element.Attributes exposing (px)
import Styles exposing (responsiveForWidth)


palette : Device -> Palette
palette device =
    { navbarButtonHeight = ( 20, 80 ) |> responsiveForWidth device |> px
    }


defaultPalette : Palette
defaultPalette =
    { navbarButtonHeight = px 0 }


type alias Palette =
    { navbarButtonHeight : Element.Attributes.Length
    }
