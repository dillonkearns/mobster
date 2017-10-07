module View.Roster.Chip exposing (view)

import Animation
import Animation.Messenger
import Element exposing (Device)
import Element.Attributes as Attr
import Element.Events
import Json.Decode
import Roster.Presenter
import Setup.Msg as Msg exposing (Msg)
import Styles exposing (StyleAttribute, StyleElement, Styles)


view :
    List StyleAttribute
    -> Msg.Msg
    -> Msg.Msg
    -> Styles.Styles
    -> Maybe (Animation.Messenger.State Msg.Msg)
    -> Device
    -> String
    -> Maybe Roster.Presenter.Role
    -> StyleElement
view additionalAttrs selectMsg removeMsg style maybeActiveMobstersStyle device name role =
    let
        iconHeight =
            Styles.responsiveForWidth device ( 10, 40 ) |> Attr.px

        padding =
            Styles.responsiveForWidth device ( 2, 14 )

        spacing =
            Styles.responsiveForWidth device ( 2, 14 )

        roleIcon =
            case role of
                Just Roster.Presenter.Driver ->
                    Element.image Styles.None
                        [ Attr.width iconHeight, Attr.height iconHeight ]
                        { src = "./assets/driver-icon.png", caption = "" }

                Just Roster.Presenter.Navigator ->
                    Element.image Styles.None
                        [ Attr.width iconHeight, Attr.height iconHeight ]
                        { src = "./assets/navigator-icon.png", caption = "" }

                Nothing ->
                    Element.image
                        Styles.None
                        [ Attr.width iconHeight, Attr.height iconHeight ]
                        { src = "./assets/transparent.png", caption = "" }

        animationAttrs =
            case maybeActiveMobstersStyle of
                Just activeMobstersStyle ->
                    List.map (\attr -> Attr.toAttr attr) (Animation.render activeMobstersStyle)

                Nothing ->
                    []
    in
    Element.row style
        (animationAttrs
            ++ additionalAttrs
            ++ [ Attr.padding padding
               , Attr.verticalCenter
               , Attr.spacing spacing
               , Element.Events.onClick selectMsg
               ]
        )
        [ roleIcon
        , Element.text name
        , removeButton removeMsg
        ]


removeButton : Msg.Msg -> StyleElement
removeButton msg =
    Element.el Styles.DeleteButton [ onClickWithoutPropagation msg ] (Element.text "×")


onClickWithoutPropagation : msg -> Element.Attribute Never msg
onClickWithoutPropagation msgConstructor =
    Element.Events.onWithOptions "click"
        { stopPropagation = True, preventDefault = False }
        (Json.Decode.succeed msgConstructor)
