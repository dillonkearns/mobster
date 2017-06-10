module Bootstrap exposing (Color(..), navbarButton, smallButton)

import FA exposing (Icon)
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events exposing (..)
import StylesheetHelper exposing (CssClasses(..), class, classList, id)


type RpgState
    = Checklist
    | NextUp


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
    button [ noTab, onClick clickMsg, Attr.class ("btn " ++ btnColorClass color ++ " btn-sm navbar-btn"), class [ BufferRight ] ]
        [ text textContent
        , span [ Attr.class faIconClass ] []
        ]


smallButton : String -> msg -> Color -> FA.Icon -> Html msg
smallButton textContent clickMsg color faIcon =
    button
        [ onClick clickMsg
        , noTab
        , Attr.class ("btn " ++ btnColorClass color ++ " btn-sm")
        , class [ BufferRight ]
        ]
        [ span [ class [ BufferRight ] ] [ text textContent ]
        , span [ Attr.class (FA.iconClass faIcon) ] []
        ]


btnColorClass : Color -> String
btnColorClass color =
    "btn-"
        ++ (color
                |> toString
                |> String.toLower
           )
