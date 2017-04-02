module Bootstrap exposing (smallButton, navbarButton, Color(..))

import Html exposing (..)
import Html.Attributes as Attr
import Html.Events exposing (..)
import Html.CssHelpers
import Setup.Stylesheet exposing (CssClasses(..))
import FA exposing (Icon)


type RpgState
    = Checklist
    | NextUp


type Color
    = Primary
    | Success
    | Warning
    | Danger


{ id, class, classList } =
    Html.CssHelpers.withNamespace "setup"
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
