module Views.Tip exposing (view)

import Element exposing (Device)
import Element.Attributes as Attr
import Element.Events
import Ipc
import Setup.Msg as Msg
import Styles exposing (StyleElement)
import Tip exposing (Tip)


view : Tip -> StyleElement
view tip =
    Element.column Styles.TipBox
        [ Attr.center
        , Attr.width Attr.fill
        , Attr.padding 20
        ]
        [ Element.text tip.title
            |> Element.el Styles.TipTitle
                [ Attr.paddingBottom 15
                , Attr.attribute "target" "_blank"
                , Element.Events.onClick (Msg.SendIpc (Ipc.OpenExternalUrl tip.url))
                ]
        , Element.column Styles.TipBody
            [ Attr.center, Attr.width (Attr.percent 55) ]
            [ [ Element.text tip.body ] |> Element.paragraph Styles.None []
            , Element.text tip.author
            ]
        ]
