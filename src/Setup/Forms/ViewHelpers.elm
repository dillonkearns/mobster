module Setup.Forms.ViewHelpers exposing (..)

import Basics.Extra exposing ((=>))
import Html exposing (..)
import Html.Attributes as Attr exposing (href, placeholder, src, style, target, title, type_, value)
import Html.Events exposing (keyCode, on, onCheck, onClick, onInput, onSubmit)
import Setup.InputField exposing (IntInputField(..))
import Setup.Msg exposing (..)
import Setup.Validations as Validations
import StylesheetHelper exposing (CssClasses(..), class, classList, id)


intInputView : IntInputField -> Int -> Html Msg
intInputView inputField duration =
    let
        ( minTimerMinutes, maxTimerMinutes ) =
            Validations.inputRangeFor inputField

        fieldId =
            toString inputField
    in
    input
        [ id fieldId
        , onClick <| SelectInputField fieldId
        , onInput <| ChangeInput (IntField inputField)
        , type_ "number"
        , Attr.min <| toString minTimerMinutes
        , Attr.max <| toString maxTimerMinutes
        , value <| toString duration
        , class [ BufferRight ]
        , style [ "font-size" => "4.0rem" ]
        ]
        []
