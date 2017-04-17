module Setup.Forms.ViewHelpers exposing (..)

import Setup.InputField exposing (IntInputField(..))
import Html exposing (..)
import Html.Attributes as Attr exposing (href, id, placeholder, src, style, target, title, type_, value)
import Html.Events exposing (keyCode, on, onCheck, onClick, onInput, onSubmit)
import Basics.Extra exposing ((=>))
import Setup.Validations as Validations
import Setup.Msg exposing (..)
import Setup.Stylesheet exposing (CssClasses(..))
import Html.CssHelpers


{ id, class, classList } =
    Html.CssHelpers.withNamespace "setup"
intInputView : IntInputField -> Int -> Html Msg
intInputView inputField duration =
    let
        ( minTimerMinutes, maxTimerMinutes ) =
            Validations.inputRangeFor inputField
    in
        input
            [ id "timer-duration"
            , onClick SelectDurationInput
            , onInput (ChangeInput (IntField inputField))
            , type_ "number"
            , Attr.min (toString minTimerMinutes)
            , Attr.max (toString maxTimerMinutes)
            , value (toString duration)
            , class [ BufferRight ]
            , style [ "font-size" => "4.0rem" ]
            ]
            []
