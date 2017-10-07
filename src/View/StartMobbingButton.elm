module View.StartMobbingButton exposing (buttonId, view)

import Element exposing (..)
import Element.Attributes as Attr exposing (..)
import Element.Events exposing (onClick, onInput)
import Setup.Msg as Msg exposing (Msg)
import Styles exposing (StyleElement)


view : { model | onMac : Bool, device : Element.Device } -> String -> StyleElement
view { onMac, device } title =
    let
        tooltipText =
            ctrlKey onMac ++ "+Enter"
    in
    column Styles.None
        [ class "styleElementsTooltipContainer" ]
        [ text title
            |> button Styles.WideButton
                [ padding (Styles.responsiveForWidth device ( 10, 20 ))
                , Element.Events.onClick Msg.StartTimer
                , Attr.id buttonId
                ]
            |> above [ el Styles.Tooltip [ center, class "styleElementsTooltip" ] (text tooltipText) ]
        ]


buttonId : String
buttonId =
    "continue-button"


ctrlKey : Bool -> String
ctrlKey onMac =
    if onMac then
        "⌘"
    else
        "Ctrl"
