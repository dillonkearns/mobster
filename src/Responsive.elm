module Responsive exposing (Palette, defaultPalette, palette)

import Element exposing (Device)
import Element.Attributes exposing (px)


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


responsiveForWidth : Device -> ( Float, Float ) -> Float
responsiveForWidth { width } rangeToScaleTo =
    Element.responsive (toFloat width) ( 600, 4000 ) rangeToScaleTo
