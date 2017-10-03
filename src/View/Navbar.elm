module View.Navbar exposing (view)

import Element exposing (..)
import Element.Attributes as Attr exposing (..)
import Element.Events exposing (onClick, onInput)
import Ipc
import Responsive
import Setup.Msg as Msg exposing (Msg)
import Setup.View exposing (ScreenState(Configure))
import Styles exposing (StyleElement)


view :
    { model
        | screenState : ScreenState
        , responsivePalette : Responsive.Palette
    }
    -> StyleElement
view ({ screenState, responsivePalette } as model) =
    let
        cogButton =
            Element.when (screenState /= Configure) (settingsPageButton model)
    in
    row Styles.Navbar
        [ Attr.spread, Attr.paddingXY 10 10, Attr.verticalCenter ]
        [ row Styles.None [ spacing 12, verticalCenter ] [ roseIcon model, el Styles.Logo [] (text "Mobster") ]
        , row Styles.None
            [ spacing 10 ]
            [ cogButton
            , Element.image Styles.None
                [ class "invisible-trigger"
                , Attr.attribute "width" "auto"
                , height responsivePalette.navbarButtonHeight
                ]
                { src = "./assets/invisible.png", caption = "invisible" }
            , navButtonView model "Hide" Styles.Warning (Msg.SendIpc Ipc.Hide)
            , navButtonView model "Quit" Styles.Danger (Msg.SendIpc Ipc.Quit)
            ]
        ]


settingsPageButton : { model | responsivePalette : Responsive.Palette } -> StyleElement
settingsPageButton { responsivePalette } =
    Element.button Styles.StepButton
        [ class "fa fa-cog"
        , height responsivePalette.navbarButtonHeight
        , width responsivePalette.navbarButtonHeight
        , verticalCenter
        , Element.Events.onClick Msg.OpenConfigure
        ]
        Element.empty


navButtonView : { model | responsivePalette : Responsive.Palette } -> String -> Styles.NavButtonType -> Msg -> StyleElement
navButtonView { responsivePalette } buttonText navButtonType msg =
    button (Styles.NavButton navButtonType)
        [ height responsivePalette.navbarButtonHeight, minWidth <| px 60, Element.Events.onClick msg ]
        (text buttonText)


roseIcon : { model | responsivePalette : Responsive.Palette } -> StyleElement
roseIcon { responsivePalette } =
    Element.image
        Styles.None
        [ Attr.height responsivePalette.navbarButtonHeight, Attr.attribute "width" "auto" ]
        { src = "./assets/rose.png", caption = "logo" }
