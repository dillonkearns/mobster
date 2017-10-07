module Setup.Shortcuts exposing (keyboardCombos)

import Array
import Basics.Extra exposing ((=>))
import Html exposing (Html, span, text, u)
import Html.Attributes as Attr exposing (style)
import Keyboard.Combo
import Setup.Msg as Msg exposing (Msg)


letters : Array.Array String
letters =
    Array.fromList [ "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p" ]


letterHint : Int -> Html msg
letterHint index =
    let
        letter =
            Maybe.withDefault "?" (Array.get index letters)
    in
    hint letter


numberHint : Int -> Html msg
numberHint index =
    let
        maybeHint =
            if index == 9 then
                Just 0
            else if index < 9 then
                Just (index + 1)
            else
                Nothing
    in
    case maybeHint of
        Just hintText ->
            hint (toString hintText)

        Nothing ->
            span [] []


hint : String -> Html msg
hint string =
    span [ Attr.class "text-muted", style [ "font-size" => "0.58em" ] ] [ text " (", u [] [ text string ], text ")" ]


keyboardCombos : List (Keyboard.Combo.KeyCombo Msg)
keyboardCombos =
    [ Keyboard.Combo.combo2 ( Keyboard.Combo.control, Keyboard.Combo.enter ) Msg.StartTimer
    , Keyboard.Combo.combo2 ( Keyboard.Combo.command, Keyboard.Combo.enter ) Msg.StartTimer
    , Keyboard.Combo.combo2 ( Keyboard.Combo.option, Keyboard.Combo.s ) Msg.SkipHotkey
    , Keyboard.Combo.combo2 ( Keyboard.Combo.alt, Keyboard.Combo.s ) Msg.SkipHotkey
    , Keyboard.Combo.combo2 ( Keyboard.Combo.alt, Keyboard.Combo.a ) (Msg.RotateInHotkey 0)
    , Keyboard.Combo.combo2 ( Keyboard.Combo.alt, Keyboard.Combo.b ) (Msg.RotateInHotkey 1)
    , Keyboard.Combo.combo2 ( Keyboard.Combo.alt, Keyboard.Combo.c ) (Msg.RotateInHotkey 2)
    , Keyboard.Combo.combo2 ( Keyboard.Combo.alt, Keyboard.Combo.d ) (Msg.RotateInHotkey 3)
    , Keyboard.Combo.combo2 ( Keyboard.Combo.alt, Keyboard.Combo.e ) (Msg.RotateInHotkey 4)
    , Keyboard.Combo.combo2 ( Keyboard.Combo.alt, Keyboard.Combo.f ) (Msg.RotateInHotkey 5)
    , Keyboard.Combo.combo2 ( Keyboard.Combo.alt, Keyboard.Combo.g ) (Msg.RotateInHotkey 6)
    , Keyboard.Combo.combo2 ( Keyboard.Combo.alt, Keyboard.Combo.h ) (Msg.RotateInHotkey 7)
    , Keyboard.Combo.combo2 ( Keyboard.Combo.alt, Keyboard.Combo.i ) (Msg.RotateInHotkey 8)
    , Keyboard.Combo.combo2 ( Keyboard.Combo.alt, Keyboard.Combo.j ) (Msg.RotateInHotkey 9)
    , Keyboard.Combo.combo2 ( Keyboard.Combo.alt, Keyboard.Combo.k ) (Msg.RotateInHotkey 10)
    , Keyboard.Combo.combo2 ( Keyboard.Combo.alt, Keyboard.Combo.l ) (Msg.RotateInHotkey 11)
    , Keyboard.Combo.combo2 ( Keyboard.Combo.alt, Keyboard.Combo.m ) (Msg.RotateInHotkey 12)
    , Keyboard.Combo.combo2 ( Keyboard.Combo.alt, Keyboard.Combo.n ) (Msg.RotateInHotkey 13)
    , Keyboard.Combo.combo2 ( Keyboard.Combo.alt, Keyboard.Combo.o ) (Msg.RotateInHotkey 14)
    , Keyboard.Combo.combo2 ( Keyboard.Combo.alt, Keyboard.Combo.p ) (Msg.RotateInHotkey 15)
    , Keyboard.Combo.combo2 ( Keyboard.Combo.alt, Keyboard.Combo.one ) (Msg.RotateOutHotkey 0)
    , Keyboard.Combo.combo2 ( Keyboard.Combo.alt, Keyboard.Combo.two ) (Msg.RotateOutHotkey 1)
    , Keyboard.Combo.combo2 ( Keyboard.Combo.alt, Keyboard.Combo.three ) (Msg.RotateOutHotkey 2)
    , Keyboard.Combo.combo2 ( Keyboard.Combo.alt, Keyboard.Combo.four ) (Msg.RotateOutHotkey 3)
    , Keyboard.Combo.combo2 ( Keyboard.Combo.alt, Keyboard.Combo.five ) (Msg.RotateOutHotkey 4)
    , Keyboard.Combo.combo2 ( Keyboard.Combo.alt, Keyboard.Combo.six ) (Msg.RotateOutHotkey 5)
    , Keyboard.Combo.combo2 ( Keyboard.Combo.alt, Keyboard.Combo.seven ) (Msg.RotateOutHotkey 6)
    , Keyboard.Combo.combo2 ( Keyboard.Combo.alt, Keyboard.Combo.eight ) (Msg.RotateOutHotkey 7)
    , Keyboard.Combo.combo2 ( Keyboard.Combo.alt, Keyboard.Combo.nine ) (Msg.RotateOutHotkey 8)
    , Keyboard.Combo.combo2 ( Keyboard.Combo.alt, Keyboard.Combo.zero ) (Msg.RotateOutHotkey 9)
    ]
