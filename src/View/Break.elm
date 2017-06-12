module View.Break exposing (view)

import Basics.Extra exposing ((=>))
import Html exposing (..)
import Html.Attributes as Attr exposing (style, target)
import Html.Events exposing (keyCode, on, onCheck, onClick, onFocus, onInput, onSubmit)
import Setup.Msg as Msg exposing (Msg)
import StylesheetHelper exposing (CssClasses(..), class, classList, id)
import Tip
import View.Tip


view : { model | secondsSinceBreak : Int, tip : Tip.Tip } -> Html Msg
view model =
    div [ Attr.class "container-fluid" ]
        [ breakAlertView model.secondsSinceBreak
        , div [ class [ BufferTop ] ] [ View.Tip.view model.tip ]
        , breakButtonsView
        ]


breakAlertView : Int -> Html msg
breakAlertView secondsSinceBreak =
    div [ Attr.class "alert alert-info alert-dismissible", style [ "font-size" => "1.2em" ] ]
        [ span [ Attr.class "glyphicon glyphicon-exclamation-sign", class [ BufferRight ] ] []
        , text ("How about a walk? You've been mobbing for " ++ toString (secondsSinceBreak // 60) ++ " minutes.")
        ]


breakButtonsView : Html Msg
breakButtonsView =
    div [ Attr.class "row", style [ "padding-bottom" => "1.333em" ] ]
        [ skipBreakButton
        , takeBreakButton
        ]


takeBreakButton : Html Msg
takeBreakButton =
    div [ Attr.class "col-md-9" ]
        [ button
            [ onClick Msg.StartBreak
            , Attr.class "btn btn-success btn-lg btn-block"
            , class [ LargeButtonText, BufferTop, TooltipContainer ]
            ]
            [ span [ class [ BufferRight ] ] [ text "Take a Break" ], i [ Attr.class "fa fa-coffee" ] [] ]
        ]


skipBreakButton : Html Msg
skipBreakButton =
    div [ Attr.class "col-md-3" ]
        [ button
            [ onClick Msg.SkipBreak
            , Attr.class "btn btn-default btn-lg btn-block"
            , class [ LargeButtonText, BufferTop, BufferRight, TooltipContainer, ButtonMuted ]
            ]
            [ span [] [ text "Skip Break" ] ]
        ]
