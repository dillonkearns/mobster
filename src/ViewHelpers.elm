module ViewHelpers exposing (..)

import Html exposing (..)
import Html.Attributes as Attr exposing (href, id, placeholder, src, style, target, title, type_, value)
import Roster.Presenter


roleIconView : Maybe Roster.Presenter.Role -> Html msg
roleIconView role =
    let
        roleIconClass =
            case role of
                Just Roster.Presenter.Driver ->
                    "driver-icon"

                Just Roster.Presenter.Navigator ->
                    "navigator-icon"

                Nothing ->
                    "no-role-icon"

        iconClassString =
            "role-icon " ++ roleIconClass
    in
    span [ Attr.class iconClassString ] []
