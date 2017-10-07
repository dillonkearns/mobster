module Setup.Navbar exposing (view)

import Basics.Extra exposing ((=>))
import Bootstrap
import Html exposing (Attribute, Html, a, div, img, nav, text)
import Html.Attributes as Attr exposing (href, src, style)
import Ipc
import Setup.Msg as Msg exposing (Msg)
import Setup.ScreenState as ScreenState exposing (ScreenState)
import StylesheetHelper exposing (CssClasses(BufferRight, Title), class)


view : ScreenState -> Html Msg
view screen =
    let
        configureScreenButton =
            case screen of
                ScreenState.Configure ->
                    text ""

                _ ->
                    Bootstrap.navbarButton "" Msg.OpenConfigure Bootstrap.Primary "cog"
    in
    nav [ Attr.class "navbar navbar-default navbar-fixed-top", style [ "background-color" => "rgba(0, 0, 0, 0.2)", "z-index" => "0" ] ]
        [ div [ Attr.class "container-fluid" ]
            [ div [ Attr.class "navbar-header" ]
                [ a [ class [ Title ], Attr.class "navbar-brand", href "#" ]
                    [ text "Mobster" ]
                ]
            , div [ Attr.class "nav navbar-nav navbar-right" ]
                [ configureScreenButton
                , invisibleTrigger [ Attr.class "navbar-btn", class [ BufferRight ] ] []
                , Bootstrap.navbarButton "Hide " (Msg.SendIpc Ipc.Hide) Bootstrap.Warning "minus-square-o"
                , Bootstrap.navbarButton "Quit " (Msg.SendIpc Ipc.Quit) Bootstrap.Danger "times-circle-o"
                ]
            ]
        ]


invisibleTrigger : List (Attribute Msg) -> List (Html Msg) -> Html Msg
invisibleTrigger additionalStyles children =
    img ([ src "./assets/invisible.png", Attr.class "invisible-trigger navbar-btn", style [ "max-width" => "2.333em" ] ] ++ additionalStyles) children
