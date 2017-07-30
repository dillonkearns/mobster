module Styles exposing (..)

import Color exposing (Color)
import Color.Mixing
import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (onClick, onInput)
import QuickRotate
import Roster.Presenter
import Setup.InputField as InputField exposing (IntInputField(..))
import Setup.Msg as Msg exposing (Msg)
import Setup.Settings as Settings
import Setup.Validations as Validations
import Style exposing (..)
import Style.Background
import Style.Border as Border
import Style.Color as Color
import Style.Filter as Filter
import Style.Font as Font
import Style.Transition
import Time


(=>) : a -> b -> ( a, b )
(=>) =
    (,)


type Styles
    = None
    | Debug
    | Main
    | Logo
    | NavOption
    | WideButton
    | NavButton NavButtonType
    | Tooltip
    | Navbar
    | RosterTable
    | ShortcutInput
    | AThing
    | Input
    | KeyboardKey
    | RoleViewName
    | AwayIcon
    | AwayX
    | TipBox
    | TipTitle
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
    | Roster
    | RosterInput
    | RosterEntry (Maybe Roster.Presenter.Role)
    | InactiveRosterEntry QuickRotate.EntrySelection
    | DeleteButton


type NavButtonType
    = Danger
    | Warning


typefaces : { title : List String, body : List String }
typefaces =
    { title = [ "Anton", "helvetica", "arial", "sans-serif" ]
    , body = [ "Lato", "Helvetica Neue", "helvetica", "arial", "sans-serif" ]
    }


responsiveForWidth : Device -> ( Float, Float ) -> Float
responsiveForWidth { width } something =
    responsive (toFloat width) ( 600, 4000 ) something


primaryColor : Color.Color
primaryColor =
    Color.white


colors : { mobButton : Color.Color, defaultButton : Color.Color, defaultButtonHover : Color.Color }
colors =
    { mobButton = Color.rgb 132 25 163, defaultButton = Color.rgb 70 70 70, defaultButtonHover = Color.rgb 50 50 50 }


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


type CircleFill
    = Filled
    | Hollow


stylesheet : Device -> StyleSheet Styles Never
stylesheet device =
    let
        fontColor =
            { tipBody = Color.rgb 235 235 235
            , tipTitle = Color.rgb 10 190 84
            , circle = Color.rgb 0 140 255
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
    Style.stylesheet
        [ style None []
        , style Debug [ Color.background (Color.rgb 74 242 161) ]
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
            , Font.size fonts.extraSmall
            , hover
                [ Color.background colors.defaultButtonHover
                ]
            ]
        , style RoleViewName
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
            , Font.typeface [ "Consolas", "Lucida Console", "monospace" ]
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
            [ Style.filters
                [ Filter.brightness 90
                ]
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
        , style NavOption
            [ Font.size 12
            , Font.typeface typefaces.body
            , Color.text (Color.rgb 255 179 116)
            ]
        , style RosterInput
            [ Color.background (Color.rgba 0 0 0 0)
            , Color.text Color.white
            , Font.typeface typefaces.body
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
                [ Color.background (Color.rgb 60 53 53)
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
                [ Color.background (Color.rgb 60 53 53)
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
                [ Color.background (Color.rgb 60 53 53)
                , Color.border (Color.rgb 60 53 53)
                ]
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
        , style Roster
            [ Border.solid
            , Border.bottom 2
            , Color.border fontColor.circle
            , Font.typeface typefaces.body
            ]
        ]


rosterItemRounding : Float
rosterItemRounding =
    4


type alias StyleElement =
    Element Styles Never Msg


inputPair : IntInputField -> String -> Int -> StyleElement
inputPair inputField label value =
    row Input
        [ spacing 20 ]
        [ numberInput value
            (Validations.inputRangeFor inputField)
            (Msg.ChangeInput (Msg.IntField inputField))
            (toString inputField)
        , el None [] <| text label
        ]


numberInput : Int -> ( Int, Int ) -> (String -> Msg) -> String -> StyleElement
numberInput value ( minValue, maxValue ) onInputMsg fieldId =
    Element.node "input" <|
        el None
            [ width <| px 60
            , minValue |> toString |> Element.Attributes.min
            , maxValue |> toString |> Element.Attributes.max
            , Element.Attributes.step "1"
            , type_ "number"
            , value |> toString |> Element.Attributes.value
            , onInput onInputMsg
            , onClick (Msg.SelectInputField fieldId)
            , id fieldId
            ]
            empty


keyBase : StyleElement -> StyleElement
keyBase =
    el KeyboardKey [ minWidth (px 60), minHeight (px 40), padding 5 ]


keyboardKey : String -> StyleElement
keyboardKey key =
    keyBase <| text key


editableKeyboardKey : String -> StyleElement
editableKeyboardKey currentKey =
    keyBase <|
        Element.inputText ShortcutInput
            [ width (px 30)
            , center
            , verticalCenter
            , inlineStyle [ "text-align" => "center" ]
            , onInput (Msg.ChangeInput (Msg.StringField Msg.ShowHideShortcut))
            ]
            currentKey


configOptions : Bool -> Settings.Data -> StyleElement
configOptions onMac settings =
    let
        breakIntervalText =
            "Break every " ++ toString (settings.intervalsPerBreak * settings.timerDuration) ++ "′"
    in
    Element.column None
        [ Element.Attributes.spacing 30, Element.Attributes.width (Element.Attributes.percent 30) ]
        [ column None
            [ spacing 10 ]
            [ inputPair InputField.TimerDuration "Minutes" settings.timerDuration
            , inputPair InputField.BreakInterval breakIntervalText settings.intervalsPerBreak
            , inputPair InputField.BreakDuration "Minutes per break" settings.breakDuration
            ]
        , column PlainBody [ spacing 8 ] [ text "Show/Hide Shortcut", row None [ spacing 10 ] [ keyboardKey (ctrlKey onMac), keyboardKey "Shift", editableKeyboardKey settings.showHideShortcut ] ]
        ]


ctrlKey : Bool -> String
ctrlKey onMac =
    if onMac then
        "⌘"
    else
        "Ctrl"


startMobbingButton : Bool -> String -> StyleElement
startMobbingButton onMac title =
    let
        tooltipText =
            if onMac then
                "⌘+Enter"
            else
                "Ctrl+Enter"
    in
    column None
        [ class "styleElementsTooltipContainer" ]
        [ (button <| el WideButton [ padding 13, Element.Events.onClick Msg.StartTimer, Element.Attributes.id "continue-button" ] (text title))
            |> above [ el Tooltip [ center, class "styleElementsTooltip" ] (text tooltipText) ]
        ]
