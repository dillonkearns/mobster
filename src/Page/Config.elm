module Page.Config exposing (view)

import Animation
import Animation.Messenger
import Basics.Extra exposing ((=>))
import Element exposing (..)
import Element.Attributes as Attr exposing (..)
import Element.Events exposing (onClick, onInput)
import Element.Input
import Html5.DragDrop as DragDrop
import Os exposing (Os)
import QuickRotate
import Responsive
import Setup.InputField as InputField exposing (IntInputField(..))
import Setup.Msg as Msg exposing (Msg)
import Setup.Settings as Settings
import Setup.Validations as Validations
import Styles exposing (StyleElement)
import View.RosterBeta
import View.StartMobbingButton


type alias DragDropModel =
    DragDrop.Model Msg.DragId Msg.DropArea


view :
    { model
        | os : Os
        , device : Element.Device
        , responsivePalette : Responsive.Palette
        , settings : Settings.Data
        , quickRotateState : QuickRotate.State
        , activeMobstersStyle : Animation.Messenger.State Msg.Msg
        , dieStyle : Animation.State
        , device : Device
        , dragDrop : DragDropModel
    }
    -> List Styles.StyleElement
view model =
    [ Element.row Styles.None
        [ Attr.spacing 50 ]
        [ configOptions model model.settings
        , Element.el Styles.None
            [ Attr.width (Attr.percent 70) ]
            (View.RosterBeta.view model model.settings.rosterData)
        ]
    , View.StartMobbingButton.view model "Start Mobbing"
    ]


inputPair : IntInputField -> String -> Int -> StyleElement
inputPair inputField label value =
    row Styles.Input
        [ spacing 20 ]
        [ numberInput value
            (Validations.inputRangeFor inputField)
            (Msg.ChangeInput (Msg.IntField inputField))
            (toString inputField)
        , el Styles.None [] <| text label
        ]


numberInput : Int -> ( Int, Int ) -> (String -> Msg) -> String -> StyleElement
numberInput value ( minValue, maxValue ) onInputMsg fieldId =
    Element.node "input" <|
        el Styles.None
            [ width <| px 60
            , minValue |> toString |> Attr.attribute "min"
            , maxValue |> toString |> Attr.attribute "max"
            , Attr.attribute "step" "1"
            , Attr.attribute "type" "number"
            , value |> toString |> Attr.attribute "value"
            , onInput onInputMsg
            , onClick (Msg.SelectInputField fieldId)
            , id fieldId
            ]
            empty


keyBase : { model | device : Element.Device } -> StyleElement -> StyleElement
keyBase { device } =
    let
        width =
            Styles.responsiveForWidth device ( 40, 120 ) |> px

        height =
            Styles.responsiveForWidth device ( 40, 120 ) |> px
    in
    el Styles.KeyboardKey [ minWidth width, minHeight height, padding 5 ]


keyboardKey : { model | device : Element.Device } -> String -> StyleElement
keyboardKey model key =
    keyBase model <| text key


editableKeyboardKey : { model | device : Element.Device } -> String -> StyleElement
editableKeyboardKey model currentKey =
    keyBase model <|
        Element.Input.text Styles.ShortcutInput
            [ width (px 30)
            , center
            , verticalCenter
            , inlineStyle [ "text-align" => "center" ]
            ]
            { onChange = Msg.ChangeInput (Msg.StringField Msg.ShowHideShortcut)
            , value = currentKey
            , label = Element.Input.hiddenLabel "show/hide shortcut"
            , options = []
            }


configOptions : { model | os : Os, device : Element.Device, responsivePalette : Responsive.Palette } -> Settings.Data -> StyleElement
configOptions ({ os } as model) settings =
    let
        breakIntervalText =
            "Break every " ++ toString (settings.intervalsPerBreak * settings.timerDuration) ++ "′"
    in
    Element.column Styles.None
        [ Attr.spacing 30, Attr.width (Attr.percent 30) ]
        [ column Styles.None
            [ spacing 10 ]
            [ inputPair InputField.TimerDuration "Minutes" settings.timerDuration
            , inputPair InputField.BreakInterval breakIntervalText settings.intervalsPerBreak
            , inputPair InputField.BreakDuration "Minutes per break" settings.breakDuration
            ]
        , column Styles.PlainBody
            [ spacing 8 ]
            [ text "Show/Hide Shortcut"
            , row Styles.None
                [ spacing 10 ]
                [ keyboardKey model (Os.ctrlKeyString os), keyboardKey model "Shift", editableKeyboardKey model settings.showHideShortcut ]
            ]
        , navButtonView model
        ]


navButtonView : { model | responsivePalette : Responsive.Palette } -> StyleElement
navButtonView { responsivePalette } =
    Element.row Styles.None
        [ width fill
        , height fill
        , center
        , verticalCenter
        , spacing 10
        ]
        [ Element.text "Learn to mob game", githubIcon ]
        |> Element.button Styles.StartRpgButton
            [ Attr.paddingXY 10 10
            , Element.Events.onClick Msg.StartRpgMode
            ]


githubIcon : StyleElement
githubIcon =
    Element.el Styles.None [ class "fa fa-gamepad" ] Element.empty
