module View.FeedbackButton exposing (view)

import Basics.Extra exposing ((=>))
import Element
import Html exposing (a, div, span, text)
import Html.Attributes as Attr
import Html.Events
import Ipc
import Setup.Msg as Msg
import Styles exposing (StyleElement)


view : StyleElement
view =
    div [ Attr.style [ "padding" => "5px" ] ]
        [ a
            [ Html.Events.onClick <| Msg.SendIpc Ipc.ShowFeedbackForm
            , Attr.style
                [ "text-transform" => "uppercase"
                , "transform" => "rotate(-90deg)"
                , "padding" => "10px"
                , "background-color" => "#464545"
                ]
            , Attr.tabindex -1
            , Attr.class "btn btn-sm btn-default pull-right"
            , Attr.id "feedback"
            ]
            [ span [ Attr.style [ "padding-right" => "10px" ] ] [ text "Feedback" ]
            , span [ Attr.class "fa fa-comment-o" ] []
            ]
        ]
        |> Element.html
