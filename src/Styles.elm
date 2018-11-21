module Styles exposing
    ( CircleFill(..)
    , NavButtonType(..)
    , StyleAttribute
    , StyleElement
    , Styles(..)
    , responsiveForWidth
    , stylesheet
    )

import Color.Mixing
import Element exposing (Device, Element)
import QuickRotate
import Roster.Presenter
import Setup.Msg as Msg exposing (Msg)
import Style exposing (..)
import Style.Background
import Style.Border as Border
import Style.Color as Color
import Style.Filter as Filter
import Style.Font as Font
import Style.Transition
import Time


white =
    rgb255 255 255 255


black =
    rgb255 0 0 0


green =
    -- TODO what was this?
    rgb255 0 255 0


type alias StyleElement =
    Element Styles Never Msg


type alias StyleAttribute =
    Element.Attribute Never Msg


type Styles
    = None
    | Main
    | RpgGoal
    | Logo
    | NavOption
    | WideButton
    | NavButton NavButtonType
    | StartRpgButton
    | Tooltip
    | Navbar
    | BreakTimer
    | RosterTable
    | ShortcutInput
    | AThing
    | Input
    | KeyboardKey
    | H1
    | NumberInputButton
    | NumberInput
    | AwayIcon
    | AwayX
    | TipBox
    | TipTitle
    | BreakTipTitle
    | RetroTipBox
    | BreakTipBox
    | PlainBody
    | TipBody
    | TipLink
    | StepButton
    | RoseIcon
    | Circle CircleFill
    | Hairline
    | BreakButton
    | SkipBreakButton
    | BreakAlertBox
    | Roster Bool
    | RosterInput Bool
    | RosterEntry (Maybe Roster.Presenter.Role)
    | RosterDraggedOver
    | InactiveRosterEntry QuickRotate.EntrySelection
    | DeleteButton
    | ShuffleDie Bool
    | ShuffleDieContainer Bool
    | UpdateAlertBox
    | UpdateNow
    | FeedbackButton


type NavButtonType
    = Danger
    | Warning


type CircleFill
    = Filled
    | Hollow


typefaces : { title : List Style.Font, body : List Style.Font }
typefaces =
    { title = [ "Anton", "helvetica", "arial", "sans-serif" ] |> List.map Font.font
    , body = [ "Lato", "Helvetica Neue", "helvetica", "arial", "sans-serif" ] |> List.map Font.font
    }


responsiveForWidth : Device -> ( Float, Float ) -> Float
responsiveForWidth { width } something =
    Element.responsive (toFloat width) ( 600, 4000 ) something


primaryColor : Style.Color
primaryColor =
    rgb255 255 255 255


rgb255 : Int -> Int -> Int -> Style.Color
rgb255 r g b =
    Style.rgb (toFloat r / 255) (toFloat g / 255) (toFloat b / 255)


rgba255 : Int -> Int -> Int -> Int -> Style.Color
rgba255 r g b a =
    Style.rgba (toFloat r / 255) (toFloat g / 255) (toFloat b / 255) (toFloat a / 255)


colors : { mobButton : Style.Color, defaultButton : Style.Color, defaultButtonHover : Style.Color }
colors =
    { mobButton = rgb255 52 152 219, defaultButton = rgb255 70 70 70, defaultButtonHover = rgb255 50 50 50 }


type alias StyleProperty =
    Style.Property Styles Never


buttonGradient : Float -> Style.Color -> StyleProperty
buttonGradient factor color =
    Style.Background.gradient 30
        [ color |> Style.Background.step
        , color |> Color.Mixing.darken factor |> Style.Background.step
        ]


buttonGradients : Float -> Color -> { main : StyleProperty, hover : StyleProperty }
buttonGradients factor color =
    { main = color |> buttonGradient factor
    , hover = color |> Color.Mixing.darken 0.04 |> buttonGradient factor
    }


stylesheet : Device -> StyleSheet Styles Never
stylesheet device =
    let
        fontColor =
            { tipBody = rgb255 235 235 235
            , tipTitle = rgb255 10 190 84
            , circle = rgb255 0 140 255
            }

        fonts :
            { mediumLarge : Float
            , medium : Float
            , mediumSmall : Float
            , mediumSmaller : Float
            , smallish : Float
            , small : Float
            , extraSmall : Float
            }
        fonts =
            { mediumLarge =
                responsiveForWidthWith ( 25, 180 )
            , medium =
                responsiveForWidthWith ( 20, 120 )
            , mediumSmall =
                responsiveForWidthWith ( 16, 80 )
            , mediumSmaller =
                responsiveForWidthWith ( 12, 70 )
            , smallish =
                responsiveForWidthWith ( 10, 50 )
            , small =
                responsiveForWidthWith ( 10, 45 )
            , extraSmall =
                responsiveForWidthWith ( 8, 38 )
            }

        responsiveForWidthWith =
            responsiveForWidth device

        rounding =
            { small = Border.rounded (responsiveForWidthWith ( 2, 10 ))
            , large = Border.rounded (responsiveForWidthWith ( 4, 20 ))
            }

        tipBoxColor =
            rgb255 75 75 75
    in
    Style.styleSheet
        [ style None []
        , style Input
            [ Font.size fonts.mediumSmaller
            ]
        , style Hairline
            [ Color.text (rgba255 55 55 55 60)
            , Border.all 1
            , Border.dashed
            ]
        , style ShortcutInput
            [ Font.uppercase
            ]
        , style NumberInput
            [ Font.center
            , Font.size fonts.mediumSmaller
            ]
        , style BreakTimer
            [ Font.center
            , Font.size fonts.mediumLarge
            ]
        , style NumberInputButton
            [ Color.background (rgba255 130 130 130 255)
            , Color.text white
            , Font.size fonts.mediumSmaller
            , Style.cursor "default"
            , hover
                [ Color.background (rgba255 95 95 95 60)
                ]
            ]
        , style (Circle Filled)
            [ Color.background fontColor.circle
            , rounding.small
            ]
        , style (Circle Hollow)
            [ rounding.small
            , Color.background (rgba255 80 80 80 60)
            ]
        , style TipBox
            [ Color.background tipBoxColor
            , rounding.small
            , Border.solid
            , Border.all 1
            , Color.border (rgb255 25 25 25)
            ]
        , style PlainBody
            [ Font.size fonts.small
            ]
        , style TipTitle
            [ Font.size fonts.mediumSmall
            , Color.text fontColor.tipTitle
            , Style.cursor "pointer"
            , Font.typeface typefaces.body
            , Font.bold
            ]
        , style BreakTipTitle
            [ Font.size fonts.mediumSmall
            , Color.text white
            , Font.typeface typefaces.body
            , Font.bold
            ]
        , style RetroTipBox
            [ Color.background fontColor.circle
            , Border.none
            , Font.typeface typefaces.body
            , Font.size fonts.small
            , Color.text primaryColor
            , rounding.small
            , Font.center
            ]
        , style BreakTipBox
            [ rgb255 8 226 108 |> Color.background

            -- TODO |> Color.Mixing.darken 0.14 |> Color.background
            , Border.none
            , Font.typeface typefaces.body
            , Font.size fonts.small
            , Color.text primaryColor
            , rounding.small
            , Font.center
            ]
        , style TipLink
            [ Font.typeface typefaces.body
            , Color.text fontColor.tipBody
            , Font.size fonts.small
            , Font.justify
            , Font.underline
            ]
        , style TipBody
            [ Font.typeface typefaces.body
            , Color.text fontColor.tipBody
            , Font.size fonts.small
            , Font.justify
            ]
        , style AwayIcon
            [ Color.text (rgb255 235 235 235)
            , Font.size fonts.extraSmall
            , Font.typeface typefaces.body
            , rounding.large
            , Color.background colors.defaultButton
            , hover
                [ Color.text (rgba255 200 20 20 255)
                , Color.background colors.defaultButtonHover
                ]
            ]
        , style AwayX
            [ Color.text (rgba255 200 20 20 255)
            , Font.size fonts.extraSmall
            , Font.typeface typefaces.body
            ]
        , style StepButton
            [ Color.text <| rgb255 239 177 1
            , Color.background colors.defaultButton
            , rounding.large
            , Border.none
            , Font.size fonts.extraSmall
            , hover
                [ Color.background colors.defaultButtonHover
                ]
            ]
        , style H1
            [ Font.size fonts.medium
            , Font.typeface typefaces.body
            ]
        , style KeyboardKey
            [ Color.text black
            , Style.Background.gradient -90 [ Style.Background.step <| white, Style.Background.step <| rgb255 207 207 207 ]
            , rounding.small
            , Font.lineHeight 2.5
            , Font.center
            , Border.solid
            , Border.all 1
            , Font.size fonts.small
            , Color.border (rgb255 170 170 170)
            , Font.typeface ([ "Droid Sans Mono", "Consolas", "Lucida Console", "monospace" ] |> List.map Font.font)
            ]
        , style Main
            [ Color.text primaryColor
            , Color.background (rgb255 34 34 34)
            , Font.typeface typefaces.body
            , Font.size 16
            , Font.lineHeight 1.3 -- line height, given as a ratio of current font size.
            ]
        , style Navbar
            [ Color.background black
            ]
        , style RosterTable
            [ Color.background green ]
        , style Logo
            [ Font.size fonts.mediumSmall
            , Font.typeface typefaces.title
            ]
        , style RoseIcon
            [ Filter.brightness 90
            ]
        , style WideButton
            [ Font.size (responsiveForWidthWith ( 22, 115 ))
            , Border.none
            , Font.typeface typefaces.title
            , colors.mobButton |> buttonGradients 0.14 |> .main
            , Color.text primaryColor
            , rounding.large
            , Font.center
            , hover
                [ colors.mobButton |> buttonGradients 0.14 |> .hover
                ]
            ]
        , style SkipBreakButton
            [ Font.size (responsiveForWidthWith ( 16, 120 ))
            , Border.none
            , Font.typeface typefaces.title
            , rgb255 186 186 186 |> buttonGradients 0.14 |> .main
            , Color.text primaryColor
            , rounding.large
            , Font.center
            , hover
                [ rgb255 186 186 186 |> buttonGradients 0.14 |> .hover
                ]
            ]
        , style BreakButton
            [ Font.size (responsiveForWidthWith ( 16, 120 ))
            , Border.none
            , Font.typeface typefaces.title
            , rgb255 8 226 108 |> buttonGradients 0.14 |> .main
            , Color.text primaryColor
            , rounding.large
            , Font.center
            , hover
                [ rgb255 8 226 108 |> buttonGradients 0.14 |> .hover
                ]
            ]
        , style BreakAlertBox
            [ Border.none
            , Font.typeface typefaces.body
            , Font.size fonts.small
            , Color.background fontColor.circle
            , Color.text primaryColor
            , rounding.small
            , Font.center
            ]
        , style Tooltip
            [ Color.background (rgb255 14 255 125)
            , Font.size 23
            , opacity 0
            , Font.typeface typefaces.title
            ]
        , style (NavButton Danger)
            [ Font.size fonts.extraSmall
            , Border.none
            , Color.text primaryColor
            , rgb255 194 12 12 |> buttonGradients 0.06 |> .main
            , rounding.small
            , Font.center
            , hover
                [ rgb255 194 12 12 |> buttonGradients 0.06 |> .hover
                ]
            , Font.typeface typefaces.body
            ]
        , style (NavButton Warning)
            [ Font.size fonts.extraSmall
            , Border.none
            , Color.text primaryColor
            , rgb255 239 177 1 |> buttonGradients 0.06 |> .main
            , rounding.small
            , Font.center
            , hover
                [ rgb255 239 177 1 |> buttonGradients 0.06 |> .hover
                ]
            , Font.typeface typefaces.body
            ]
        , style StartRpgButton
            [ Font.size fonts.extraSmall
            , Border.none
            , Color.text primaryColor
            , rgb255 55 90 127 |> buttonGradients 0.06 |> .main
            , rounding.small
            , Font.center
            , hover
                [ rgb255 35 70 107 |> buttonGradients 0.06 |> .hover
                ]
            , Font.typeface typefaces.body
            ]
        , style NavOption
            [ Font.size 12
            , Font.typeface typefaces.body
            , Color.text (rgb255 255 179 116)
            ]
        , style RpgGoal
            [ Style.cursor "pointer"
            , Font.size fonts.smallish
            ]
        , style (RosterInput True)
            [ Color.background (rgba255 0 0 0 0)
            , Color.text white
            , Font.size fonts.small
            ]
        , style (RosterInput False)
            [ Color.background (rgba255 0 0 0 0)
            , Color.text white
            , Font.size fonts.small
            ]
        , style RosterDraggedOver
            [ Color.background (rgb255 8 226 108)
            , rounding.small
            , Font.size fonts.small
            , Color.text white
            , Font.typeface typefaces.body
            , hover
                [ Color.background (rgb255 8 226 108)
                ]
            ]
        , style (RosterEntry (Just Roster.Presenter.Driver))
            [ Color.background fontColor.circle
            , rounding.small
            , Font.size fonts.small
            , Color.text white
            , Font.typeface typefaces.body
            , hover
                [ Color.background (rgb255 0 95 210)
                ]
            ]
        , style (RosterEntry (Just Roster.Presenter.Navigator))
            [ Color.background (rgb255 140 133 133)
            , rounding.small
            , Color.text white
            , Font.size fonts.small
            , Font.typeface typefaces.body
            , hover
                [ Color.background (rgb255 90 83 83)
                ]
            ]
        , style (RosterEntry Nothing)
            [ Color.background (rgb255 140 133 133)
            , rounding.small
            , Color.text white
            , Font.size fonts.small
            , Font.typeface typefaces.body
            , hover
                [ Color.background (rgb255 90 83 83)
                ]
            ]
        , style (InactiveRosterEntry QuickRotate.Selected)
            [ Color.background (rgb255 0 140 255)
            , rounding.small
            , Color.text white
            , Font.size fonts.small
            , Color.border (rgb255 233 224 103)
            , Border.solid
            , Border.all 1
            , Font.typeface typefaces.body
            , hover
                [ Color.background (rgb255 140 133 133)
                ]
            ]
        , style (InactiveRosterEntry QuickRotate.Matches)
            [ Color.background (rgb255 0 50 95)
            , rounding.small
            , Color.border (rgb255 233 224 103)
            , Border.solid
            , Border.all 1
            , Color.text white
            , Font.size fonts.small
            , Font.typeface typefaces.body
            , hover
                [ Color.background (rgb255 140 133 133)
                ]
            ]
        , style (InactiveRosterEntry QuickRotate.NoMatch)
            [ Color.background (rgb255 80 73 73)
            , rounding.small
            , Color.text white
            , Color.border (rgb255 80 73 73)
            , Border.solid
            , Border.all 1
            , Font.size fonts.small
            , Font.typeface typefaces.body
            , hover
                [ Color.background (rgb255 140 133 133)
                , Color.border (rgb255 60 53 53)
                ]
            ]
        , style UpdateAlertBox
            [ Color.background (rgb255 0 188 140)
            , Font.size fonts.extraSmall
            , rounding.small
            ]
        , style UpdateNow
            [ Style.cursor "pointer"
            , Font.underline
            , Font.bold
            ]
        , style FeedbackButton
            [ Color.background (rgb255 70 69 69)
            , Border.all 3
            , Color.border white
            , Font.uppercase
            , rotate90DegreesCounterClockwise
            , hover
                [ Color.background (rgb255 50 49 49)
                ]
            ]
        , style (ShuffleDieContainer False)
            [ Color.background (rgb255 68 68 68)
            ]
        , style (ShuffleDieContainer True)
            [ Color.background (rgb255 68 68 68)
            ]
        , style (ShuffleDie False)
            [ Style.opacity 0.5
            , Style.Transition.transitions
                [ { delay = 0
                  , duration = 500
                  , easing = "ease"
                  , props = [ "all" ]
                  }
                ]
            ]
        , style (ShuffleDie True)
            [ Style.opacity 1
            , Style.Transition.transitions
                [ { delay = 0
                  , duration = 500
                  , easing = "ease"
                  , props = [ "all" ]
                  }
                ]
            ]
        , style DeleteButton
            [ Color.text white
            , Style.Transition.transitions
                [ { delay = 0
                  , duration = 500
                  , easing = "ease"
                  , props = [ "all" ]
                  }
                ]
            , hover
                [ Color.text (rgb255 194 12 12)
                , Font.bold
                ]
            , Style.cursor "pointer"
            ]
        , style (Roster True)
            [ Border.solid
            , Border.bottom 2
            , Color.border fontColor.circle
            , Font.typeface typefaces.body
            , Style.Transition.transitions
                [ { delay = 0
                  , duration = 500
                  , easing = "ease"
                  , props = [ "all" ]
                  }
                ]
            ]
        , style (Roster False)
            [ Border.solid
            , Border.bottom 2
            , Color.border (rgb255 140 133 133)
            , Font.typeface typefaces.body
            , Style.Transition.transitions
                [ { delay = 0
                  , duration = 500
                  , easing = "ease"
                  , props = [ "all" ]
                  }
                ]
            ]
        ]


rotate90DegreesCounterClockwise : StyleProperty
rotate90DegreesCounterClockwise =
    Style.rotate -1.5708
