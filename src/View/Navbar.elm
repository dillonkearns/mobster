module View.Navbar exposing (view)

import Element
import Element.Attributes as Attr
import Element.Events
import Ipc
import Responsive
import Setup.Msg as Msg exposing (Msg)
import Setup.ScreenState as ScreenState exposing (ScreenState)
import Styles exposing (StyleElement)


view :
    { model
        | screenState : ScreenState
        , responsivePalette : Responsive.Palette
    }
    -> StyleElement
view ({ screenState } as model) =
    let
        cogButton =
            if screenState /= ScreenState.Configure then
                settingsPageButton model

            else
                Element.empty
    in
    Element.row Styles.Navbar
        [ Attr.spread, Attr.paddingXY 10 10, Attr.verticalCenter ]
        [ Element.row Styles.None [ Attr.spacing 12, Attr.verticalCenter ] [ roseIcon model, Element.el Styles.Logo [] (Element.text "Mobster") ]
        , Element.row Styles.None
            [ Attr.spacing 10 ]
            [ cogButton
            , invisibleTrigger model
            , navButtonView model "Hide" Styles.Warning (Msg.SendIpc Ipc.Hide)
            , navButtonView model "Quit" Styles.Danger (Msg.SendIpc Ipc.Quit)
            ]
        ]


invisibleTrigger :
    { b | responsivePalette : Responsive.Palette }
    -> StyleElement
invisibleTrigger { responsivePalette } =
    Element.image Styles.None
        [ Attr.class "invisible-trigger"
        , Attr.attribute "width" "auto"
        , Attr.height responsivePalette.navbarButtonHeight
        ]
        { src = "./assets/invisible.png", caption = "invisible" }


settingsPageButton : { model | responsivePalette : Responsive.Palette } -> StyleElement
settingsPageButton { responsivePalette } =
    Element.button Styles.StepButton
        [ Attr.class "fa fa-cog"
        , Attr.height responsivePalette.navbarButtonHeight
        , Attr.width responsivePalette.navbarButtonHeight
        , Attr.verticalCenter
        , Element.Events.onClick Msg.OpenConfigure
        ]
        Element.empty


navButtonView : { model | responsivePalette : Responsive.Palette } -> String -> Styles.NavButtonType -> Msg -> StyleElement
navButtonView { responsivePalette } buttonText navButtonType msg =
    Element.button (Styles.NavButton navButtonType)
        [ Attr.height responsivePalette.navbarButtonHeight, responsivePalette.navbarPadding, Element.Events.onClick msg ]
        (Element.text buttonText)


roseIcon : { model | responsivePalette : Responsive.Palette } -> StyleElement
roseIcon { responsivePalette } =
    Element.image
        Styles.None
        [ Attr.height responsivePalette.navbarButtonHeight, Attr.attribute "width" "auto" ]
        { src = "./assets/rose.png", caption = "logo" }
