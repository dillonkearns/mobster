module View.Break exposing (view)

import Basics.Extra exposing ((=>))
import Html exposing (..)
import Html.Attributes as Attr exposing (style, target)
import Html.Events exposing (keyCode, on, onCheck, onClick, onFocus, onInput, onSubmit)
import Ipc
import Json.Encode as Encode
import Setup.Msg as Msg exposing (Msg)
import StylesheetHelper exposing (CssClasses(..), class, classList, id)
import Tip


view : { model | secondsSinceBreak : Int, tip : Tip.Tip } -> Html Msg
view model =
    div [ Attr.class "container-fluid" ]
        [ breakAlertView model.secondsSinceBreak
        , div [ class [ BufferTop ] ] [ tipView model.tip ]
        , breakButtonsView
        ]


breakAlertView : Int -> Html msg
breakAlertView secondsSinceBreak =
    div [ Attr.class "alert alert-info alert-dismissible", style [ "font-size" => "1.2em" ] ]
        [ span [ Attr.class "glyphicon glyphicon-exclamation-sign", class [ BufferRight ] ] []
        , text ("How about a walk? You've been mobbing for " ++ toString (secondsSinceBreak // 60) ++ " minutes.")
        ]


tipView : Tip.Tip -> Html Msg
tipView tip =
    div [ Attr.class "jumbotron tip", style [ "margin" => "0px", "padding" => "1.667em" ] ]
        [ div [ Attr.class "row" ]
            [ h2 [ Attr.class "text-success pull-left", style [ "margin" => "0px", "padding-bottom" => "0.667em" ] ]
                [ text tip.title ]
            , a [ Attr.tabindex -1, target "_blank", Attr.class "btn btn-sm btn-primary pull-right", onClick <| Msg.SendIpc Ipc.OpenExternalUrl (Encode.string tip.url) ] [ text "Learn More" ]
            ]
        , div [ Attr.class "row" ] [ Tip.tipView tip ]
        ]


breakButtonsView : Html Msg
breakButtonsView =
    div [ Attr.class "row", style [ "padding-bottom" => "1.333em" ] ]
        [ div [ Attr.class "col-md-3" ]
            [ button
                [ onClick Msg.SkipBreak
                , Attr.class "btn btn-default btn-lg btn-block"
                , class [ LargeButtonText, BufferTop, BufferRight, TooltipContainer, ButtonMuted ]
                ]
                [ span [] [ text "Skip Break" ] ]
            ]
        , div [ Attr.class "col-md-9" ]
            [ button
                [ onClick Msg.StartBreak
                , Attr.class "btn btn-success btn-lg btn-block"
                , class [ LargeButtonText, BufferTop, TooltipContainer ]
                ]
                [ span [ class [ BufferRight ] ] [ text "Take a Break" ], i [ Attr.class "fa fa-coffee" ] [] ]
            ]
        ]
