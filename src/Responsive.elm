module Responsive exposing (Palette, defaultPalette, palette)

import Element exposing (Device)
import Element.Attributes as Attr exposing (px)
import Styles exposing (StyleAttribute)


palette : Device -> Palette
palette device =
    { navbarButtonHeight = ( 20, 80 ) |> responsiveForWidth device |> px
    , inputWidth = ( 25, 115 ) |> responsiveForWidth device |> px
    , navbarPadding = Attr.paddingXY (( 10, 20 ) |> responsiveForWidth device) (( 5, 10 ) |> responsiveForWidth device)
    }


defaultPalette : Palette
defaultPalette =
    { navbarButtonHeight = px 0
    , inputWidth = px 0
    , navbarPadding = Attr.paddingXY 0 0
    }


type alias Palette =
    { navbarButtonHeight : Attr.Length
    , inputWidth : Attr.Length
    , navbarPadding : StyleAttribute
    }


responsiveForWidth : Device -> ( Float, Float ) -> Float
responsiveForWidth { width } rangeToScaleTo =
    Element.responsive (toFloat width) ( 600, 4000 ) rangeToScaleTo
