module Styles exposing (..)

import Color exposing (Color)
import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (onInput)
import Setup.Msg as Msg exposing (Msg)
import Setup.Settings as Settings
import Style exposing (..)
import Style.Background
import Style.Border as Border
import Style.Color as Color
import Style.Font as Font


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
    | AThing
    | InputLabel
    | Input
    | KeyboardKey
    | ShortcutInput


type NavButtonType
    = Danger
    | Warning


fonts : { title : List String, body : List String }
fonts =
    { title = [ "Anton", "helvetica", "arial", "sans-serif" ], body = [ "Open Sans Condensed", "Helvetica Neue", "helvetica", "arial", "sans-serif" ] }


primaryColor : Color
primaryColor =
    Color.white


stylesheet : Element.Device -> StyleSheet Styles variation
stylesheet device =
    let
        mediumFontSize =
            Element.responsive (toFloat device.width) ( 600, 1200 ) ( 28, 45 )

        mediumSmallFontSize =
            Element.responsive (toFloat device.width) ( 600, 2000 ) ( 19, 30 )

        smallFontSize =
            Element.responsive (toFloat device.width) ( 600, 2000 ) ( 14, 20 )
    in
    Style.stylesheet
        [ style None []
        , style Debug [ Color.background (Color.rgb 74 242 161) ]
        , style Input
            [ Font.size mediumSmallFontSize
            ]
        , style InputLabel
            [--Color.text (Color.rgb 246 217 30)
             -- Color.text (Color.rgb 0 168 251)
             -- Color.text (Color.rgb 74 242 161)
             -- Color.text (Color.rgb 255 245 211)
             -- Color.text (Color.rgb 255 220 255)
            ]
        , style ShortcutInput
            [ Font.uppercase
            ]
        , style KeyboardKey
            [ Color.text Color.black
            , Style.Background.gradient -90 [ Style.Background.step <| Color.white, Style.Background.step <| Color.rgb 207 207 207 ]
            , Border.rounded 3
            , Font.lineHeight 2.5
            , Font.center
            , Border.solid
            , Border.all 1
            , Font.size smallFontSize
            , Color.border (Color.rgb 170 170 170)
            , Font.typeface [ "Consolas", "Lucida Console", "monospace" ]
            ]
        , style Main
            [ Color.text primaryColor
            , Color.background (Color.rgb 40 40 40)
            , Font.typeface fonts.body
            , Font.size 16
            , Font.lineHeight 1.3 -- line height, given as a ratio of current font size.
            ]
        , style Navbar
            [ Color.background Color.black
            ]
        , style RosterTable
            [ Color.background Color.green ]
        , style Logo
            [ Font.size mediumFontSize
            , Font.typeface fonts.title
            ]
        , style WideButton
            [ Font.size (Element.responsive (toFloat device.width) ( 600, 4000 ) ( 35, 100 ))
            , Border.none
            , Font.typeface fonts.title
            , Style.Background.gradient 30 [ Style.Background.step <| Color.rgb 132 25 163, Style.Background.step <| Color.rgb 83 3 105 ]
            , Color.text primaryColor
            , Border.rounded 10
            , Font.center
            , hover
                [ Style.Background.gradient 30 [ Style.Background.step <| Color.rgb 117 25 163, Style.Background.step <| Color.rgb 68 3 105 ]
                ]
            ]
        , style Tooltip
            [ Color.background (Color.rgb 201 201 201)
            , Font.size 28
            , opacity 0
            , Font.typeface fonts.body
            ]
        , style (NavButton Danger)
            [ Font.size smallFontSize
            , Border.none
            , Color.text primaryColor
            , Style.Background.gradient 30 [ Style.Background.step <| Color.rgb 194 12 12, Style.Background.step <| Color.rgb 174 12 12 ]
            , Border.rounded 5
            , Font.center
            , hover
                [ Style.Background.gradient 30 [ Style.Background.step <| Color.rgb 174 2 2, Style.Background.step <| Color.rgb 154 0 0 ]
                ]
            , Font.typeface fonts.body
            ]
        , style (NavButton Warning)
            [ Font.size smallFontSize
            , Border.none
            , Color.text primaryColor
            , Style.Background.gradient 30 [ Style.Background.step <| Color.rgb 239 177 1, Style.Background.step <| Color.rgb 244 182 11 ]
            , Border.rounded 5
            , Font.center
            , hover
                [ Style.Background.gradient 30 [ Style.Background.step <| Color.rgb 219 157 1, Style.Background.step <| Color.rgb 224 162 1 ]
                ]
            , Font.typeface fonts.body
            ]
        , style NavOption
            [ Font.size 12
            , Font.typeface fonts.body
            , Color.text (Color.rgb 255 179 116)
            ]
        ]


type alias StyleElement =
    Element Styles Never Msg


navbar : StyleElement
navbar =
    row Navbar
        [ justify, paddingXY 10 10, verticalCenter ]
        [ row None [ spacing 12 ] [ roseIcon, el Logo [] (text "Mobster") ]
        , row None
            [ spacing 20 ]
            [ Element.image "./assets/invisible.png" None [ width (px 40), height (px 40) ] Element.empty
            , navButtonView "Hide" Warning
            , navButtonView "Quit" Danger
            ]
        ]


navButtonView : String -> NavButtonType -> StyleElement
navButtonView buttonText navButtonType =
    button <| el (NavButton navButtonType) [ minWidth <| px 60, height <| px 34 ] (text buttonText)


inputPair : String -> String -> StyleElement
inputPair label value =
    row Input [ spacing 20 ] [ Element.inputText None [ width <| px 50 ] value, el InputLabel [] <| text label ]


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


configOptions : Settings.Data -> StyleElement
configOptions settings =
    Element.column None
        [ Element.Attributes.spacing 30 ]
        [ column None
            [ spacing 10 ]
            [ inputPair "Minutes" "5"
            , inputPair "Break every 25'" "5"
            , inputPair "Minutes per break" "5"
            ]
        , column None [ spacing 8 ] [ text "Show/Hide Shortcut", row None [ spacing 10 ] [ keyboardKey "⌘", keyboardKey "Shift", editableKeyboardKey settings.showHideShortcut ] ]
        ]


startMobbingButton : StyleElement
startMobbingButton =
    column None
        [ class "styleElementsTooltipContainer" ]
        [ (button <| el WideButton [ padding 13, Element.Events.onClick Msg.StartTimer ] (text "Start Mobbing"))
            |> above [ el Tooltip [ center, width (px 200), class "styleElementsTooltip" ] (text "⌘+Enter") ]
        ]


roseIcon : StyleElement
roseIcon =
    Element.image "./assets/rose.png" None [ height (px 40), width (px 25) ] Element.empty
