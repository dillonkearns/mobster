module Page.Config exposing (view)

import Animation
import Animation.Messenger
import Basics.Extra exposing ((=>))
import Dict exposing (Dict)
import Element exposing (Device)
import Element.Attributes as Attr
import Element.Events exposing (onClick, onInput)
import Element.Input
import Html5.DragDrop as DragDrop
import Os exposing (Os)
import QuickRotate
import Responsive
import Setup.InputField as InputField exposing (IntInputField)
import Setup.Msg as Msg exposing (Msg)
import Setup.Settings as Settings
import Setup.Validations as Validations
import Styles exposing (StyleElement)
import View.Roster
import View.ShuffleDie
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
        , manualChangeCounter : Int
        , dirtyInputKeys : Dict String Int
        , shuffleButtonHover : Bool
    }
    -> List Styles.StyleElement
view model =
    [ Element.row Styles.None
        [ Attr.spacing 50 ]
        [ configOptions model model.settings
        , Element.row Styles.None
            [ Attr.width (Attr.fillPortion 68) ]
            [ View.Roster.view model model.settings.rosterData
            , View.ShuffleDie.view model
            ]
        ]
    , View.StartMobbingButton.view model "Start Mobbing"
    ]


inputPair : { model | dirtyInputKeys : Dict String Int, responsivePalette : Responsive.Palette } -> IntInputField -> String -> Int -> StyleElement
inputPair model inputField label value =
    Element.row Styles.Input
        [ Attr.spacing 20 ]
        [ numberInput model
            value
            (Validations.inputRangeFor inputField)
            (Msg.ChangeInput (Msg.IntField inputField))
            inputField
        , Element.el Styles.None [] <| Element.text label
        ]


plusMinusButton : String -> Msg -> StyleElement
plusMinusButton stringy msg =
    Element.text stringy
        |> Element.el Styles.NumberInputButton
            [ Attr.paddingXY 10 0
            , Attr.verticalCenter
            , Attr.height (Attr.percent 100)
            , Element.Events.onClick msg
            ]


numberInput : { model | dirtyInputKeys : Dict String Int, responsivePalette : Responsive.Palette } -> Int -> ( Int, Int ) -> (String -> Msg) -> IntInputField -> StyleElement
numberInput { dirtyInputKeys, responsivePalette } value ( minValue, maxValue ) onInputMsg inputField =
    let
        plusMsg =
            Msg.ChangeInput (Msg.IntField inputField) (value + 1 |> toString)

        minusMsg =
            Msg.ChangeInput (Msg.IntField inputField) (value - 1 |> toString)

        fieldId =
            toString inputField
    in
    Element.row Styles.None
        []
        [ plusMinusButton "–" minusMsg
        , Element.Input.text Styles.NumberInput
            [ responsivePalette.inputWidth |> Attr.width
            , minValue |> toString |> Attr.attribute "min"
            , maxValue |> toString |> Attr.attribute "max"
            , Attr.attribute "step" "1"
            , Attr.attribute "type" "number"
            , value |> toString |> Attr.attribute "value"
            , onClick (Msg.SelectInputField fieldId)
            , Attr.id fieldId
            ]
            { onChange = Msg.ChangeInput (Msg.IntField inputField)
            , value = value |> toString
            , label = Element.Input.hiddenLabel "input"
            , options = [ Element.Input.textKey (Dict.get fieldId dirtyInputKeys |> Maybe.withDefault -1 |> toString) ]
            }
        , plusMinusButton "+" plusMsg
        ]


keyBase : { model | device : Element.Device } -> StyleElement -> StyleElement
keyBase { device } =
    let
        width =
            Styles.responsiveForWidth device ( 40, 120 ) |> Attr.px

        height =
            Styles.responsiveForWidth device ( 40, 120 ) |> Attr.px
    in
    Element.el Styles.KeyboardKey [ Attr.minWidth width, Attr.minHeight height, Attr.padding 5 ]


keyboardKey : { model | device : Element.Device } -> String -> StyleElement
keyboardKey model key =
    keyBase model <| Element.text key


editableKeyboardKey : { model | device : Element.Device } -> String -> StyleElement
editableKeyboardKey model currentKey =
    keyBase model <|
        Element.Input.text Styles.ShortcutInput
            [ Attr.width (Attr.px 30)
            , Attr.center
            , Attr.verticalCenter
            , Attr.inlineStyle [ "text-align" => "center" ]
            ]
            { onChange = Msg.ChangeInput (Msg.StringField Msg.ShowHideShortcut)
            , value = currentKey
            , label = Element.Input.hiddenLabel "show/hide shortcut"
            , options = []
            }


configOptions :
    { model
        | os : Os
        , device : Element.Device
        , responsivePalette : Responsive.Palette
        , dirtyInputKeys : Dict String Int
    }
    -> Settings.Data
    -> StyleElement
configOptions ({ os } as model) settings =
    let
        breakIntervalText =
            "Break every " ++ toString (settings.intervalsPerBreak * settings.timerDuration) ++ "′"
    in
    Element.column Styles.None
        [ Attr.spacing 30, Attr.width (Attr.fillPortion 32) ]
        [ Element.column Styles.None
            [ Attr.spacing 10 ]
            [ inputPair model InputField.TimerDuration "Minutes" settings.timerDuration
            , inputPair model InputField.BreakInterval breakIntervalText settings.intervalsPerBreak
            , inputPair model InputField.BreakDuration "Minutes per break" settings.breakDuration
            ]
        , Element.column Styles.PlainBody
            [ Attr.spacing 8 ]
            [ Element.text "Show/Hide Shortcut"
            , Element.row Styles.None
                [ Attr.spacing 10 ]
                [ keyboardKey model (Os.ctrlKeyString os), keyboardKey model "Shift", editableKeyboardKey model settings.showHideShortcut ]
            ]
        , navButtonView model
        ]


navButtonView : { model | responsivePalette : Responsive.Palette } -> StyleElement
navButtonView _ =
    Element.row Styles.None
        [ Attr.width Attr.fill
        , Attr.height Attr.fill
        , Attr.center
        , Attr.verticalCenter
        , Attr.spacing 10
        ]
        [ Element.text "Learn to mob game", githubIcon ]
        |> Element.button Styles.StartRpgButton
            [ Attr.paddingXY 10 10
            , Element.Events.onClick Msg.StartRpgMode
            ]


githubIcon : StyleElement
githubIcon =
    Element.el Styles.None [ Attr.class "fa fa-gamepad" ] Element.empty
