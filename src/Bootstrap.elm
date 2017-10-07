module Bootstrap exposing (Color(Danger, Primary, Success, Warning), navbarButton, smallButton)

import FA
import Html exposing (Attribute, Html, button, span, text)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import StylesheetHelper exposing (class)


type Color
    = Primary
    | Success
    | Warning
    | Danger


noTab : Attribute msg
noTab =
    Attr.tabindex -1


navbarButton : String -> msg -> Color -> String -> Html msg
navbarButton textContent clickMsg color faIcon =
    let
        faIconClass =
            if faIcon == "" then
                ""
            else
                "fa fa-" ++ faIcon
    in
    button [ noTab, onClick clickMsg, Attr.class ("btn " ++ btnColorClass color ++ " btn-sm navbar-btn"), class [ StylesheetHelper.BufferRight ] ]
        [ text textContent
        , span [ Attr.class faIconClass ] []
        ]


smallButton : String -> msg -> Color -> FA.Icon -> Html msg
smallButton textContent clickMsg color faIcon =
    button
        [ onClick clickMsg
        , noTab
        , Attr.class ("btn " ++ btnColorClass color ++ " btn-sm")
        , class [ StylesheetHelper.BufferRight ]
        ]
        [ span [ class [ StylesheetHelper.BufferRight ] ] [ text textContent ]
        , span [ Attr.class (FA.iconClass faIcon) ] []
        ]


btnColorClass : Color -> String
btnColorClass color =
    "btn-"
        ++ (color
                |> toString
                |> String.toLower
           )
