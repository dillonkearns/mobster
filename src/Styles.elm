module Styles
    exposing
        ( CircleFill(..)
        , NavButtonType(..)
        , StyleAttribute
        , StyleElement
        , Styles(..)
        , responsiveForWidth
        , stylesheet
        )

import Color exposing (Color)
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
    | GameButton
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


primaryColor : Color.Color
primaryColor =
    Color.white


colors : { mobButton : Color.Color, defaultButton : Color.Color, defaultButtonHover : Color.Color }
colors =
    { mobButton = Color.rgb 52 152 219, defaultButton = Color.rgb 70 70 70, defaultButtonHover = Color.rgb 50 50 50 }


type alias StyleProperty =
    Style.Property Styles Never


buttonGradient : Color.Mixing.Factor -> Color -> StyleProperty
buttonGradient factor color =
    Style.Background.gradient 30
        [ color |> Style.Background.step
        , color |> Color.Mixing.darken factor |> Style.Background.step
        ]


buttonGradients : Color.Mixing.Factor -> Color -> { main : StyleProperty, hover : StyleProperty }
buttonGradients factor color =
    { main = color |> buttonGradient factor
    , hover = color |> Color.Mixing.darken 0.04 |> buttonGradient factor
    }


stylesheet : Device -> StyleSheet Styles Never
stylesheet device =
    let
        fontColor =
            { tipBody = Color.rgb 235 235 235
            , tipTitle = Color.rgb 10 190 84
            , circle = Color.rgb 0 140 255
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

        tipBoxColor =
            Color.rgb 75 75 75
    in
    Style.styleSheet
        [ style None []
        , style Input
            [ Font.size fonts.mediumSmaller
            ]
        , style Hairline
            [ Color.text (Color.rgba 55 55 55 60)
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
            [ Color.background (Color.rgba 130 130 130 255)
            , Color.text Color.white
            , Font.size fonts.mediumSmaller
            , Style.cursor "default"
            , hover
                [ Color.background (Color.rgba 95 95 95 60)
                ]
            ]
        , style (Circle Filled)
            [ Color.background fontColor.circle
            , Border.rounded 3
            ]
        , style (Circle Hollow)
            [ Border.rounded 3
            , Color.background (Color.rgba 80 80 80 60)
            ]
        , style TipBox
            [ Color.background tipBoxColor
            , Border.rounded 3
            , Border.solid
            , Border.all 1
            , Color.border (Color.rgb 25 25 25)
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
            , Color.text Color.white
            , Font.typeface typefaces.body
            , Font.bold
            ]
        , style RetroTipBox
            [ Color.background fontColor.circle
            , Border.none
            , Font.typeface typefaces.body
            , Font.size fonts.small
            , Color.text primaryColor
            , Border.rounded 3
            , Font.center
            ]
        , style BreakTipBox
            [ Color.rgb 8 226 108 |> Color.Mixing.darken 0.14 |> Color.background
            , Border.none
            , Font.typeface typefaces.body
            , Font.size fonts.small
            , Color.text primaryColor
            , Border.rounded 3
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
            [ Color.text (Color.rgb 235 235 235)
            , Font.size fonts.extraSmall
            , Font.typeface typefaces.body
            , Border.rounded 10
            , Color.background colors.defaultButton
            , hover
                [ Color.text (Color.rgba 200 20 20 255)
                , Color.background colors.defaultButtonHover
                ]
            ]
        , style AwayX
            [ Color.text (Color.rgba 200 20 20 255)
            , Font.size fonts.extraSmall
            , Font.typeface typefaces.body
            ]
        , style StepButton
            [ Color.text <| Color.rgb 239 177 1
            , Color.background colors.defaultButton
            , Border.rounded 10
            , Border.none
            , Font.size fonts.extraSmall
            , hover
                [ Color.background colors.defaultButtonHover
                ]
            ]
        , style GameButton
            [ Color.text <| Color.white
            , Color.background colors.defaultButton
            , Border.rounded 10
            , Border.none
            , Font.size fonts.small
            , hover
                [ Color.background colors.defaultButtonHover
                ]
            ]
        , style H1
            [ Font.size fonts.medium
            , Font.typeface typefaces.body
            ]
        , style KeyboardKey
            [ Color.text Color.black
            , Style.Background.gradient -90 [ Style.Background.step <| Color.white, Style.Background.step <| Color.rgb 207 207 207 ]
            , Border.rounded 3
            , Font.lineHeight 2.5
            , Font.center
            , Border.solid
            , Border.all 1
            , Font.size fonts.small
            , Color.border (Color.rgb 170 170 170)
            , Font.typeface ([ "Droid Sans Mono", "Consolas", "Lucida Console", "monospace" ] |> List.map Font.font)
            ]
        , style Main
            [ Color.text primaryColor
            , Color.background (Color.rgb 34 34 34)
            , Font.typeface typefaces.body
            , Font.size 16
            , Font.lineHeight 1.3 -- line height, given as a ratio of current font size.
            ]
        , style Navbar
            [ Color.background Color.black
            ]
        , style RosterTable
            [ Color.background Color.green ]
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
            , Border.rounded 6
            , Font.center
            , hover
                [ colors.mobButton |> buttonGradients 0.14 |> .hover
                ]
            ]
        , style SkipBreakButton
            [ Font.size (responsiveForWidthWith ( 16, 120 ))
            , Border.none
            , Font.typeface typefaces.title
            , Color.rgb 186 186 186 |> buttonGradients 0.14 |> .main
            , Color.text primaryColor
            , Border.rounded 10
            , Font.center
            , hover
                [ Color.rgb 186 186 186 |> buttonGradients 0.14 |> .hover
                ]
            ]
        , style BreakButton
            [ Font.size (responsiveForWidthWith ( 16, 120 ))
            , Border.none
            , Font.typeface typefaces.title
            , Color.rgb 8 226 108 |> buttonGradients 0.14 |> .main
            , Color.text primaryColor
            , Border.rounded 10
            , Font.center
            , hover
                [ Color.rgb 8 226 108 |> buttonGradients 0.14 |> .hover
                ]
            ]
        , style BreakAlertBox
            [ Border.none
            , Font.typeface typefaces.body
            , Font.size fonts.small
            , Color.background fontColor.circle
            , Color.text primaryColor
            , Border.rounded 3
            , Font.center
            ]
        , style Tooltip
            [ Color.background (Color.rgb 14 255 125)
            , Font.size 23
            , opacity 0
            , Font.typeface typefaces.title
            ]
        , style (NavButton Danger)
            [ Font.size fonts.extraSmall
            , Border.none
            , Color.text primaryColor
            , Color.rgb 194 12 12 |> buttonGradients 0.06 |> .main
            , Border.rounded 5
            , Font.center
            , hover
                [ Color.rgb 194 12 12 |> buttonGradients 0.06 |> .hover
                ]
            , Font.typeface typefaces.body
            ]
        , style (NavButton Warning)
            [ Font.size fonts.extraSmall
            , Border.none
            , Color.text primaryColor
            , Color.rgb 239 177 1 |> buttonGradients 0.06 |> .main
            , Border.rounded 5
            , Font.center
            , hover
                [ Color.rgb 239 177 1 |> buttonGradients 0.06 |> .hover
                ]
            , Font.typeface typefaces.body
            ]
        , style StartRpgButton
            [ Font.size fonts.extraSmall
            , Border.none
            , Color.text primaryColor
            , Color.rgb 55 90 127 |> buttonGradients 0.06 |> .main
            , Border.rounded 5
            , Font.center
            , hover
                [ Color.rgb 35 70 107 |> buttonGradients 0.06 |> .hover
                ]
            , Font.typeface typefaces.body
            ]
        , style NavOption
            [ Font.size 12
            , Font.typeface typefaces.body
            , Color.text (Color.rgb 255 179 116)
            ]
        , style RpgGoal
            [ Style.cursor "pointer"
            , Font.size fonts.smallish
            ]
        , style (RosterInput True)
            [ Color.background (Color.rgba 0 0 0 0)
            , Color.text Color.white
            , Font.size fonts.small
            ]
        , style (RosterInput False)
            [ Color.background (Color.rgba 0 0 0 0)
            , Color.text Color.white
            , Font.size fonts.small
            ]
        , style RosterDraggedOver
            [ Color.background (Color.rgb 8 226 108)
            , Border.rounded rosterItemRounding
            , Font.size fonts.small
            , Color.text Color.white
            , Font.typeface typefaces.body
            , hover
                [ Color.background (Color.rgb 8 226 108)
                ]
            ]
        , style (RosterEntry (Just Roster.Presenter.Driver))
            [ Color.background fontColor.circle
            , Border.rounded rosterItemRounding
            , Font.size fonts.small
            , Color.text Color.white
            , Font.typeface typefaces.body
            , hover
                [ Color.background (Color.rgb 0 95 210)
                ]
            ]
        , style (RosterEntry (Just Roster.Presenter.Navigator))
            [ Color.background (Color.rgb 140 133 133)
            , Border.rounded rosterItemRounding
            , Color.text Color.white
            , Font.size fonts.small
            , Font.typeface typefaces.body
            , hover
                [ Color.background (Color.rgb 90 83 83)
                ]
            ]
        , style (RosterEntry Nothing)
            [ Color.background (Color.rgb 140 133 133)
            , Border.rounded rosterItemRounding
            , Color.text Color.white
            , Font.size fonts.small
            , Font.typeface typefaces.body
            , hover
                [ Color.background (Color.rgb 90 83 83)
                ]
            ]
        , style (InactiveRosterEntry QuickRotate.Selected)
            [ Color.background (Color.rgb 0 140 255)
            , Border.rounded rosterItemRounding
            , Color.text Color.white
            , Font.size fonts.small
            , Color.border (Color.rgb 233 224 103)
            , Border.solid
            , Border.all 1
            , Font.typeface typefaces.body
            , hover
                [ Color.background (Color.rgb 140 133 133)
                ]
            ]
        , style (InactiveRosterEntry QuickRotate.Matches)
            [ Color.background (Color.rgb 0 50 95)
            , Border.rounded rosterItemRounding
            , Color.border (Color.rgb 233 224 103)
            , Border.solid
            , Border.all 1
            , Color.text Color.white
            , Font.size fonts.small
            , Font.typeface typefaces.body
            , hover
                [ Color.background (Color.rgb 140 133 133)
                ]
            ]
        , style (InactiveRosterEntry QuickRotate.NoMatch)
            [ Color.background (Color.rgb 80 73 73)
            , Border.rounded rosterItemRounding
            , Color.text Color.white
            , Color.border (Color.rgb 80 73 73)
            , Border.solid
            , Border.all 1
            , Font.size fonts.small
            , Font.typeface typefaces.body
            , hover
                [ Color.background (Color.rgb 140 133 133)
                , Color.border (Color.rgb 60 53 53)
                ]
            ]
        , style (ShuffleDie False)
            [ Style.opacity 0.5
            ]
        , style (ShuffleDie True)
            [ Style.opacity 1
            ]
        , style UpdateAlertBox
            [ Color.background (Color.rgb 0 188 140)
            , Font.size fonts.extraSmall
            , Border.rounded 3
            ]
        , style UpdateNow
            [ Style.cursor "pointer"
            , Font.underline
            , Font.bold
            ]
        , style FeedbackButton
            [ Color.background (Color.rgb 70 69 69)
            , Border.all 3
            , Color.border Color.white
            , Font.uppercase
            , rotate90DegreesCounterClockwise
            , hover
                [ Color.background (Color.rgb 50 49 49)
                ]
            ]
        , style (ShuffleDieContainer False)
            [ Color.background (Color.rgb 48 48 48)
            ]
        , style (ShuffleDieContainer True)
            [ Color.background (Color.rgb 48 48 48)
            ]
        , style DeleteButton
            [ Color.text Color.white
            , Style.Transition.transitions
                [ { delay = 0
                  , duration = Time.millisecond * 500
                  , easing = "ease"
                  , props = [ "all" ]
                  }
                ]
            , hover
                [ Color.text (Color.rgb 194 12 12)
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
                  , duration = Time.millisecond * 500
                  , easing = "ease"
                  , props = [ "all" ]
                  }
                ]
            ]
        , style (Roster False)
            [ Border.solid
            , Border.bottom 2
            , Color.border (Color.rgb 140 133 133)
            , Font.typeface typefaces.body
            , Style.Transition.transitions
                [ { delay = 0
                  , duration = Time.millisecond * 500
                  , easing = "ease"
                  , props = [ "all" ]
                  }
                ]
            ]
        ]


rotate90DegreesCounterClockwise : StyleProperty
rotate90DegreesCounterClockwise =
    Style.rotate -1.5708


rosterItemRounding : Float
rosterItemRounding =
    4
