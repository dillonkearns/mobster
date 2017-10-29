module View.FeedbackButtonStyleElements exposing (view)

import Element
import Element.Attributes as Attr
import Element.Events
import Ipc
import Setup.Msg as Msg
import Styles exposing (StyleElement)


view : StyleElement
view =
    [ Element.text "Feedback", fa Styles.None "fa-comment-o" ]
        |> Element.row Styles.FeedbackButton
            [ Attr.padding 10
            , Attr.spacing 10
            , Element.Events.onClick <| Msg.SendIpc Ipc.ShowFeedbackForm
            ]


fa : Styles.Styles -> String -> StyleElement
fa style faClass =
    Element.el style [ Attr.class <| "fa " ++ faClass ] Element.empty
