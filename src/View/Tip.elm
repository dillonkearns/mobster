module View.Tip exposing (view)

import Basics.Extra exposing ((=>))
import Html exposing (..)
import Html.Attributes as Attr exposing (style, target)
import Html.Events exposing (onClick)
import Ipc
import Setup.Msg as Msg exposing (Msg)
import Tip


view : Tip.Tip -> Html Msg
view tip =
    div [ Attr.class "jumbotron tip", style [ "margin" => "0px", "padding" => "1.667em" ] ]
        [ div [ Attr.class "row" ]
            [ h2 [ Attr.class "text-success pull-left", style [ "margin" => "0px", "padding-bottom" => "0.667em" ] ]
                [ text tip.title ]
            , a [ Attr.tabindex -1, target "_blank", Attr.class "btn btn-sm btn-primary pull-right", onClick <| Msg.SendIpc (Ipc.OpenExternalUrl tip.url) ] [ text "Learn More" ]
            ]
        , div [ Attr.class "row" ] [ Tip.tipView tip ]
        ]
