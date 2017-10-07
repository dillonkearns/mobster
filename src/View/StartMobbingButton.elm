module View.StartMobbingButton exposing (buttonId, view, viewWithMsg)

import Element
import Element.Attributes as Attr
import Element.Events
import Os exposing (Os)
import Setup.Msg as Msg exposing (Msg)
import Styles exposing (StyleElement)


view : { model | os : Os, device : Element.Device } -> String -> StyleElement
view { os, device } title =
    let
        tooltipText =
            Os.ctrlKeyString os ++ "+Enter"
    in
    Element.column Styles.None
        [ Attr.class "styleElementsTooltipContainer" ]
        [ Element.text title
            |> Element.button Styles.WideButton
                [ Attr.padding (Styles.responsiveForWidth device ( 10, 20 ))
                , Element.Events.onClick Msg.StartTimer
                , Attr.id buttonId
                ]
            |> Element.above
                [ Element.el Styles.Tooltip
                    [ Attr.center
                    , Attr.class "styleElementsTooltip"
                    ]
                    (Element.text tooltipText)
                ]
        ]


viewWithMsg : { model | os : Os, device : Element.Device } -> String -> Msg -> StyleElement
viewWithMsg { os, device } title msg =
    let
        tooltipText =
            Os.ctrlKeyString os ++ "+Enter"
    in
    Element.column Styles.None
        [ Attr.class "styleElementsTooltipContainer" ]
        [ Element.text title
            |> Element.button Styles.WideButton
                [ Attr.padding (Styles.responsiveForWidth device ( 10, 20 ))
                , Element.Events.onClick msg
                , Attr.id buttonId
                ]
            |> Element.above
                [ Element.el Styles.Tooltip
                    [ Attr.center
                    , Attr.class "styleElementsTooltip"
                    ]
                    (Element.text tooltipText)
                ]
        ]


buttonId : String
buttonId =
    "continue-button"
