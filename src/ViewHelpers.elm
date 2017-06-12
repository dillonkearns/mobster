module ViewHelpers exposing (..)

import Basics.Extra exposing ((=>))
import Html exposing (..)
import Html.Attributes as Attr exposing (href, id, placeholder, src, style, target, title, type_, value)
import Html.Events exposing (onClick)
import Roster.Presenter
import StylesheetHelper exposing (CssClasses(..), class, classList, id)


blockButton : String -> msg -> String -> String -> Html msg
blockButton displayText onClickMsg tooltipText buttonId =
    div [ Attr.class "row", style [ "padding-bottom" => "1.333em" ] ]
        [ button
            [ onClick onClickMsg
            , Attr.class "btn btn-info btn-lg btn-block"
            , class [ LargeButtonText, BufferTop, TooltipContainer, Title ]
            , Attr.id buttonId
            ]
            [ div [] [ text displayText ]
            , div [ class [ Tooltip ] ] [ text tooltipText ]
            ]
        ]


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
