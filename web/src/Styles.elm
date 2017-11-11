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
    | Tooltip
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
            , Color.background (Color.rgb 40 40 40)
            , Font.size 16
            , Font.lineHeight 1.3
            ]
        , style DownloadButton
            [ Color.background (Color.rgb 10 190 84 |> Color.Mixing.darken 0.02)
            , Font.center
            , Border.rounded 5
            , Style.Shadow.simple
            , Font.size 30
            , hover
                [ cursor "pointer"
                , Color.background (Color.rgb 10 190 84 |> Color.Mixing.darken 0.1)
                ]
            ]
        , style Navbar
            [ Color.background Color.white
            ]
        , style Tooltip
            [ Color.background (Color.rgb 201 201 201)
            , Font.size 28
            , opacity 0
            ]
        , style Title
            [ Font.typeface typefaces.title
            , Color.text (Color.rgb 57 64 64)
            , Font.size 40
            ]
        , style SubHeading
            [ Color.text (Color.rgb 57 64 64)
            , Font.size 25
            , Font.weight 900
            ]
        , style StarCount
            [ Color.background (Color.rgb 240 240 240)
            , Border.all 2
            , Color.border (Color.rgb 195 195 195)
            , hover
                [ Color.background (Color.rgb 240 240 240 |> Color.Mixing.darken 0.2)
                , Color.text (Color.rgb 57 64 64)
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
            , Color.text (Color.rgb 57 64 64)
            ]
        , style NavbarLink
            [ Font.size 35
            , Color.text (Color.rgb 57 64 64)
            , hover
                [ Color.text (Color.rgb 52 152 219)
                ]
            ]
        , style TaglineA
            [ Font.size 35

            -- , Font.weight 900
            --  , Color.text (Color.rgb 57 64 64)
            ]
        , style TaglineB
            [ Font.size 35
            , Font.weight 900

            --  , Color.text (Color.rgb 57 64 64)
            ]
        ]
