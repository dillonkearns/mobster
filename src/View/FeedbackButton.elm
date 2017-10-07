module View.FeedbackButton exposing (view)

import Basics.Extra exposing ((=>))
import Element
import Html exposing (a, div, span, text)
import Html.Attributes as Attr exposing (placeholder, src, style, target, title, type_, value)
import Html.Events exposing (keyCode, on, onCheck, onClick, onFocus, onInput, onSubmit)
import Ipc
import Setup.Msg as Msg exposing (Msg)
import Styles exposing (StyleElement)


view : StyleElement
view =
    div [ style [ "padding" => "5px" ] ]
        [ a
            [ onClick <| Msg.SendIpc Ipc.ShowFeedbackForm
            , style
                [ "text-transform" => "uppercase"
                , "transform" => "rotate(-90deg)"
                , "padding" => "10px"
                , "background-color" => "#464545"
                ]
            , Attr.tabindex -1
            , Attr.class "btn btn-sm btn-default pull-right"
            , Attr.id "feedback"
            ]
            [ span [ style [ "padding-right" => "10px" ] ] [ text "Feedback" ]
            , span [ Attr.class "fa fa-comment-o" ] []
            ]
        ]
        |> Element.html
