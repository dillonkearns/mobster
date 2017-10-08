module View.Roster.Chip exposing (view)

import Animation
import Animation.Messenger
import Element exposing (Device)
import Element.Attributes as Attr
import Element.Events
import Html5.DragDrop as DragDrop
import Json.Decode
import QuickRotate
import Roster.Presenter
import Setup.Msg as Msg exposing (Msg)
import Styles exposing (StyleAttribute, StyleElement)


type alias DragDropModel =
    DragDrop.Model Msg.DragId Msg.DropArea


view :
    { model
        | quickRotateState : QuickRotate.State
        , activeMobstersStyle : Animation.Messenger.State Msg
        , dieStyle : Animation.State
        , device : Device
        , dragDrop : DragDropModel
    }
    -> List StyleAttribute
    -> Msg
    -> Msg
    -> Styles.Styles
    -> Maybe (Animation.Messenger.State Msg)
    -> String
    -> Maybe Roster.Presenter.Role
    -> ( String, StyleElement )
view { device } additionalAttrs selectMsg removeMsg style maybeActiveMobstersStyle name role =
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
    ( name
    , Element.row style
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
    )


removeButton : Msg.Msg -> StyleElement
removeButton msg =
    Element.el Styles.DeleteButton [ onClickWithoutPropagation msg ] (Element.text "×")


onClickWithoutPropagation : msg -> Element.Attribute Never msg
onClickWithoutPropagation msgConstructor =
    Element.Events.onWithOptions "click"
        { stopPropagation = True, preventDefault = False }
        (Json.Decode.succeed msgConstructor)
