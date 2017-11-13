module Styles exposing (StyleElement, StyleProperty, Styles(..), stylesheet)

import Color exposing (Color)
import Color.Mixing
import Element exposing (..)
import Msg exposing (Msg)
import Style exposing (..)
import Style.Border as Border
import Style.Color as Color
import Style.Font as Font
import Style.Shadow


type alias StyleElement =
    Element Styles Never Msg


type Styles
    = None
    | TopLevel
    | Main
    | Navbar
    | DownloadButton
    | Title
    | SubHeading
    | StarCount
    | OtherPlatformsLink
    | NavbarLink
    | NavbarLinks
    | TaglineA
    | TaglineB


type alias StyleProperty =
    Style.Property Styles Never


colors : { bg : { dark : Color }, green : Color, text : { darkBold : Color, darkRegular : Color }, blue : Color }
colors =
    { blue = Color.rgb 52 152 219
    , green = Color.rgb 9 180 80
    , text =
        { darkBold = Color.rgb 38 38 38
        , darkRegular = Color.rgb 57 64 64
        }
    , bg =
        { dark = Color.rgb 40 40 40 }
    }


colorToString : Color -> String
colorToString color =
    color
        |> Color.toRgb
        |> (\{ red, green, blue } -> [ red, green, blue ])
        |> List.map toString
        |> String.join ","
        |> (\rgb -> "rgb(" ++ rgb ++ ")")


typefaces : { title : List Style.Font, body : List Style.Font }
typefaces =
    { title = [ "Anton", "helvetica", "arial", "sans-serif" ] |> List.map Font.font
    , body = [ "Lato", "Helvetica Neue", "helvetica", "arial", "sans-serif" ] |> List.map Font.font
    }


primaryColor : Color.Color
primaryColor =
    Color.white


responsiveForWidth : Device -> ( Float, Float ) -> Float
responsiveForWidth { width } getInitialWindowSize =
    responsive (toFloat width) ( 600, 4000 ) getInitialWindowSize


stylesheet : Device -> StyleSheet Styles Never
stylesheet device =
    let
        responsiveForWidthWith =
            responsiveForWidth device

        mediumLargeFontSize =
            responsiveForWidthWith ( 25, 180 )

        mediumFontSize =
            responsiveForWidthWith ( 28, 65 )

        mediumSmallFontSize =
            responsiveForWidthWith ( 20, 60 )

        smallFontSize =
            responsiveForWidthWith ( 10, 45 )

        extraSmallFontSize =
            responsiveForWidthWith ( 8, 38 )
    in
    Style.styleSheet
        [ style None []
        , style TopLevel
            [ Font.typeface typefaces.body
            , Font.size 16
            ]
        , style Main
            [ Color.text primaryColor
            , Color.background colors.bg.dark
            , Font.size 16
            , Font.lineHeight 1.3
            ]
        , style DownloadButton
            [ Color.background colors.green
            , Font.center
            , Border.rounded 5
            , Style.Shadow.simple
            , Font.size 30
            , hover
                [ cursor "pointer"
                , Color.background (colors.green |> Color.Mixing.darken 0.1)
                ]
            ]
        , style Navbar
            [ Color.background Color.white
            ]
        , style Title
            [ Font.typeface typefaces.title
            , Color.text colors.text.darkBold
            , Font.size 40
            , Style.prop "fill" (colorToString colors.text.darkBold)
            , hover
                [ cursor "pointer"
                ]
            ]
        , style SubHeading
            [ Color.text colors.text.darkRegular
            , Font.size 25
            , Font.weight 900
            ]
        , style StarCount
            [ Color.background (Color.rgb 240 240 240)
            , Border.all 2
            , Color.border (Color.rgb 195 195 195)
            , Style.prop "fill" (colorToString colors.text.darkBold)
            , hover
                [ Color.background (Color.rgb 240 240 240 |> Color.Mixing.darken 0.2)
                , Style.cursor "pointer"
                ]
            ]
        , style OtherPlatformsLink
            [ Font.size 12
            , Font.underline
            , Color.text (Color.rgb 200 200 200)
            , Font.center
            , hover
                [ Color.text (Color.rgb 200 200 200 |> Color.Mixing.darken 0.2)
                ]
            ]
        , style NavbarLinks
            [ Font.size 35
            , Color.text colors.text.darkBold
            ]
        , style NavbarLink
            [ Font.size 35
            , Color.text colors.text.darkBold
            , Style.prop "fill" (colorToString colors.text.darkBold)
            , hover
                [ Color.text colors.blue
                , Style.prop "fill" (colorToString colors.blue)
                , cursor "pointer"
                ]
            ]
        , style TaglineA
            [ Font.size 35
            ]
        , style TaglineB
            [ Font.size 35
            , Font.weight 900
            ]
        ]
