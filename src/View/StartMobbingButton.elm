module View.StartMobbingButton exposing (buttonId, view)

import Element exposing (..)
import Element.Attributes as Attr exposing (..)
import Element.Events exposing (onClick, onInput)
import Os exposing (Os)
import Setup.Msg as Msg exposing (Msg)
import Styles exposing (StyleElement)


view : { model | os : Os, device : Element.Device } -> String -> StyleElement
view { os, device } title =
    let
        tooltipText =
            Os.ctrlKeyString os ++ "+Enter"
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
