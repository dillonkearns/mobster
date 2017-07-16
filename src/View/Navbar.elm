module View.Navbar exposing (view)

import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (onClick, onInput)
import Setup.Msg as Msg exposing (Msg)
import Setup.View exposing (ScreenState)
import Styles exposing (StyleElement)


view : { model | screenState : ScreenState } -> StyleElement
view { screenState } =
    row Styles.Navbar
        [ justify, paddingXY 10 10, verticalCenter ]
        [ row Styles.None [ spacing 12 ] [ roseIcon, el Styles.Logo [] (text "Mobster") ]
        , row Styles.None
            [ spacing 20 ]
            [ Element.image "./assets/invisible.png" Styles.None [ width (px 40), height (px 40) ] Element.empty
            , navButtonView "Hide" Styles.Warning Msg.hide
            , navButtonView "Quit" Styles.Danger Msg.quit
            ]
        ]


navButtonView : String -> Styles.NavButtonType -> Msg -> StyleElement
navButtonView buttonText navButtonType msg =
    button <| el (Styles.NavButton navButtonType) [ minWidth <| px 60, height <| px 34, Element.Events.onClick msg ] (text buttonText)


roseIcon : StyleElement
roseIcon =
    Element.image "./assets/rose.png" Styles.None [ height (px 40), width (px 25) ] Element.empty
