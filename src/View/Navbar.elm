module View.Navbar exposing (view)

import Element exposing (..)
import Element.Attributes as Attr exposing (..)
import Element.Events exposing (onClick, onInput)
import Ipc
import Setup.Msg as Msg exposing (Msg)
import Setup.View exposing (ScreenState(Configure))
import Styles exposing (StyleElement)


view : { model | screenState : ScreenState, device : Device } -> StyleElement
view ({ screenState, device } as model) =
    let
        cogButton =
            Element.when (screenState /= Configure) (settingsPageButton model)

        iconDimensions =
            responsive (toFloat device.width) ( 600, 4000 ) ( 24, 66 )

        buttonHeight =
            Styles.responsiveForWidth device ( 20, 80 )
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
                , height (px buttonHeight)
                ]
                { src = "./assets/invisible.png", caption = "invisible" }
            , navButtonView model "Hide" Styles.Warning (Msg.SendIpc Ipc.Hide)
            , navButtonView model "Quit" Styles.Danger (Msg.SendIpc Ipc.Quit)
            ]
        ]


settingsPageButton : { model | device : Element.Device } -> StyleElement
settingsPageButton { device } =
    let
        buttonHeight =
            Styles.responsiveForWidth device ( 20, 80 )
    in
    Element.button Styles.StepButton
        [ class "fa fa-cog"
        , height (px buttonHeight)
        , width (px buttonHeight)
        , verticalCenter
        , Element.Events.onClick Msg.OpenConfigure
        ]
        Element.empty


navButtonView : { model | device : Element.Device } -> String -> Styles.NavButtonType -> Msg -> StyleElement
navButtonView { device } buttonText navButtonType msg =
    let
        buttonHeight =
            Styles.responsiveForWidth device ( 20, 80 )
    in
    button (Styles.NavButton navButtonType)
        [ height (px buttonHeight), minWidth <| px 60, Element.Events.onClick msg ]
        (text buttonText)


roseIcon : { model | device : Device } -> StyleElement
roseIcon { device } =
    let
        ( width, height ) =
            ( Styles.responsiveForWidth device ( 12, 40 ) |> Attr.px
            , Styles.responsiveForWidth device ( 18, 70 ) |> Attr.px
            )
    in
    Element.image
        Styles.None
        [ Attr.height height, Attr.width width ]
        { src = "./assets/rose.png", caption = "logo" }
