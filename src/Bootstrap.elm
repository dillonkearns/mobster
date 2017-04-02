module Bootstrap exposing (navbarButton, BootstrapColor(..))

import Html exposing (..)
import Html.Attributes as Attr
import Html.Events exposing (..)
import Html.CssHelpers
import Setup.Stylesheet exposing (CssClasses(..))


type RpgState
    = Checklist
    | NextUp


{ id, class, classList } =
    Html.CssHelpers.withNamespace "setup"
type BootstrapColor
    = Primary
    | Success
    | Warning
    | Danger


noTab : Attribute msg
noTab =
    Attr.tabindex -1


navbarButton : String -> msg -> BootstrapColor -> String -> Html msg
navbarButton textContent clickMsg color faIcon =
    let
        btnColorClass =
            "btn-"
                ++ (color
                        |> toString
                        |> String.toLower
                   )

        faIconClass =
            if faIcon == "" then
                ""
            else
                "fa fa-" ++ faIcon
    in
        button [ noTab, onClick clickMsg, Attr.class ("btn " ++ btnColorClass ++ " btn-sm navbar-btn"), class [ BufferRight ] ]
            [ text textContent
            , span [ Attr.class faIconClass ] []
            ]
