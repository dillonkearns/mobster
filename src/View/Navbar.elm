module View.Navbar exposing (view)

import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (onClick, onInput)
import Setup.Msg as Msg exposing (Msg)
import Setup.View exposing (ScreenState(Configure))
import Styles exposing (StyleElement)


view : { model | screenState : ScreenState } -> StyleElement
view { screenState } =
    let
        cogButton =
            Element.when (screenState /= Configure) settingsPageButton
    in
    row Styles.Navbar
        [ justify, paddingXY 10 10, verticalCenter ]
        [ row Styles.None [ spacing 12 ] [ roseIcon, el Styles.Logo [] (text "Mobster") ]
        , row Styles.None
            [ spacing 20 ]
            [ cogButton
            , Element.image "./assets/invisible.png" Styles.None [ width (px 40), height (px 40) ] Element.empty
            , navButtonView "Hide" Styles.Warning Msg.hide
            , navButtonView "Quit" Styles.Danger Msg.quit
            ]
        ]


settingsPageButton : StyleElement
settingsPageButton =
    Element.el Styles.StepButton
        [ paddingXY 16 10
        , class "fa fa-cog"
        , verticalCenter
        , Element.Events.onClick Msg.OpenConfigure
        ]
        Element.empty


navButtonView : String -> Styles.NavButtonType -> Msg -> StyleElement
navButtonView buttonText navButtonType msg =
    button <| el (Styles.NavButton navButtonType) [ minWidth <| px 60, height <| px 34, Element.Events.onClick msg ] (text buttonText)


roseIcon : StyleElement
roseIcon =
    Element.image "./assets/rose.png" Styles.None [ height (px 40), width (px 25) ] Element.empty
