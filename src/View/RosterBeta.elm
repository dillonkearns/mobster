module View.RosterBeta exposing (preventAddingMobster, view)

import Animation
import Animation.Messenger
import Element exposing (Device, el)
import Element.Attributes as Attr
import Element.Events
import Element.Input
import Html5.DragDrop as DragDrop
import Json.Decode
import QuickRotate
import Roster.Data as Mobster
import Roster.Operation
import Roster.Presenter
import Roster.Rpg
import Setup.Msg as Msg exposing (Msg)
import Styles exposing (StyleElement)
import View.Roster.Chip


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
    ->
        { inactiveMobsters :
            List { name : String, rpgData : Roster.Rpg.RpgData }
        , mobsters : List Mobster.Mobster
        , nextDriver : Int
        }
    -> StyleElement
view model rosterData =
    Element.row Styles.None
        []
        [ rosterView model rosterData
        , shuffleDieContainer model
        ]


rosterView :
    { model
        | quickRotateState : QuickRotate.State
        , activeMobstersStyle : Animation.Messenger.State Msg
        , dieStyle : Animation.State
        , device : Device
        , dragDrop : DragDropModel
    }
    ->
        { inactiveMobsters :
            List { name : String, rpgData : Roster.Rpg.RpgData }
        , mobsters : List Mobster.Mobster
        , nextDriver : Int
        }
    -> StyleElement
rosterView ({ quickRotateState, device } as model) rosterData =
    let
        inactiveMobsters =
            rosterData.inactiveMobsters

        matches =
            QuickRotate.matches (inactiveMobsters |> List.map .name) quickRotateState

        -- TODO: use this in the new beta roster
        newMobsterDisabled =
            preventAddingMobster rosterData.mobsters quickRotateState.query

        inactiveTagInputHighlighted =
            case quickRotateState.selection of
                QuickRotate.Index _ ->
                    True

                _ ->
                    False
    in
    Element.column Styles.None
        [ Attr.spacing 30, Attr.width (Attr.percent 100) ]
        [ Element.column Styles.None
            []
            [ el Styles.PlainBody [] <| Element.text "Active"
            , activeView model rosterData
            ]
        , Element.column Styles.None
            []
            [ el Styles.PlainBody [] <| Element.text "Inactive"
            , Element.wrappedRow (Styles.Roster inactiveTagInputHighlighted)
                [ Attr.width (Attr.percent 100), Attr.padding 5, Attr.spacing 10 ]
                (List.indexedMap (inactiveMobsterView device quickRotateState.query quickRotateState.selection matches)
                    (inactiveMobsters |> List.map .name)
                )
            ]
        ]


activeView :
    { model
        | quickRotateState : QuickRotate.State
        , activeMobstersStyle : Animation.Messenger.State Msg
        , dieStyle : Animation.State
        , device : Device
        , dragDrop : DragDropModel
    }
    ->
        { inactiveMobsters :
            List { rpgData : Roster.Rpg.RpgData, name : String }
        , nextDriver : Int
        , mobsters : List Mobster.Mobster
        }
    -> StyleElement
activeView ({ quickRotateState } as model) rosterData =
    let
        activeMobsters =
            Roster.Presenter.mobsters rosterData

        highlighted =
            case quickRotateState.selection of
                QuickRotate.Index _ ->
                    False

                _ ->
                    True
    in
    Element.wrappedRow (Styles.Roster highlighted)
        [ Attr.width (Attr.percent 100), Attr.padding 5, Attr.spacing 10 ]
        (List.map (activeMobsterView model) activeMobsters
            ++ [ rosterInput quickRotateState.query quickRotateState.selection ]
        )


activeMobsterView :
    { model
        | quickRotateState : QuickRotate.State
        , activeMobstersStyle : Animation.Messenger.State Msg
        , dieStyle : Animation.State
        , device : Device
        , dragDrop : DragDropModel
    }
    -> Roster.Presenter.MobsterWithRole
    -> StyleElement
activeMobsterView ({ dragDrop, device, activeMobstersStyle } as model) mobster =
    let
        isBeingDraggedOver =
            case ( DragDrop.getDragId dragDrop, DragDrop.getDropId dragDrop ) of
                ( Just (Msg.ActiveMobster _), Just (Msg.DropActiveMobster id) ) ->
                    id == mobster.index

                _ ->
                    False

        chipStyle =
            if isBeingDraggedOver then
                Styles.RosterDraggedOver
            else
                Styles.RosterEntry mobster.role
    in
    View.Roster.Chip.view (dragDropAttrs mobster.index)
        (Msg.UpdateRosterData (Roster.Operation.SetNextDriver mobster.index))
        (Msg.UpdateRosterData (Roster.Operation.Bench mobster.index))
        chipStyle
        (Just activeMobstersStyle)
        device
        mobster.name
        mobster.role


dragDropAttrs : Int -> List (Element.Attribute Never Msg)
dragDropAttrs mobsterIndex =
    DragDrop.draggable Msg.DragDropMsg (Msg.ActiveMobster mobsterIndex)
        ++ DragDrop.droppable Msg.DragDropMsg (Msg.DropActiveMobster mobsterIndex)
        |> List.map Attr.toAttr


inactiveMobsterView : Device -> String -> QuickRotate.Selection -> List Int -> Int -> String -> StyleElement
inactiveMobsterView device quickRotateQuery quickRotateSelection matches mobsterIndex mobsterName =
    let
        selectionType =
            QuickRotate.selectionTypeFor mobsterIndex matches quickRotateSelection
    in
    View.Roster.Chip.view []
        (Msg.UpdateRosterData (Roster.Operation.RotateIn mobsterIndex))
        (Msg.UpdateRosterData (Roster.Operation.Remove mobsterIndex))
        (Styles.InactiveRosterEntry selectionType)
        Nothing
        device
        mobsterName
        Nothing


rosterInput : String -> QuickRotate.Selection -> StyleElement
rosterInput query selection =
    let
        highlightSelection =
            case selection of
                QuickRotate.New _ ->
                    True

                _ ->
                    False

        dec =
            Json.Decode.map
                (\code ->
                    if code == 38 then
                        Ok (Msg.QuickRotateMove Msg.Previous)
                    else if code == 9 || code == 40 then
                        Ok (Msg.QuickRotateMove Msg.Next)
                    else if code == 13 then
                        Ok Msg.QuickRotateAdd
                    else
                        Err "not handling that key"
                )
                Element.Events.keyCode
                |> Json.Decode.andThen
                    fromResult

        fromResult : Result String a -> Json.Decode.Decoder a
        fromResult result =
            case result of
                Ok val ->
                    Json.Decode.succeed val

                Err reason ->
                    Json.Decode.fail reason

        options =
            { preventDefault = True, stopPropagation = False }
    in
    Element.el Styles.None [ Attr.id "add-mobster-container" ] <|
        Element.Input.text (Styles.RosterInput highlightSelection)
            [ Attr.verticalCenter
            , Attr.attribute "placeholder" "+ Mobster"
            , Attr.id quickRotateQueryId
            , Attr.height (Attr.percent 100)
            , Attr.width Attr.fill
            , Element.Events.onWithOptions "keydown" options dec
            ]
            { onChange = Msg.ChangeInput (Msg.StringField Msg.QuickRotateQuery)
            , value = query
            , label = Element.Input.hiddenLabel "Add mobster"
            , options = []
            }


quickRotateQueryId : String
quickRotateQueryId =
    "quick-rotate-query"


shuffleDie :
    { model
        | dieStyle : Animation.State
        , device : Device
    }
    -> StyleElement
shuffleDie { dieStyle, device } =
    let
        dimension =
            Styles.responsiveForWidth device ( 20, 50 ) |> Attr.px
    in
    Element.image
        Styles.ShuffleDie
        (List.map (\attr -> Attr.toAttr attr) (Animation.render dieStyle)
            ++ [ Element.Events.onClick Msg.ShuffleMobsters
               , Attr.height dimension
               , Attr.width dimension
               ]
        )
        { src = "./assets/dice.png", caption = "Shuffle die" }


shuffleDieContainer :
    { model
        | dieStyle : Animation.State
        , device : Device
    }
    -> StyleElement
shuffleDieContainer ({ dieStyle, device } as model) =
    let
        dimension =
            Styles.responsiveForWidth device ( 40, 100 ) |> Attr.px
    in
    Element.el Styles.ShuffleDieContainer [ Attr.width dimension, Attr.height dimension ] <|
        -- The extra container is needed to center, setting it directly
        -- on the image conflicts with the style animation css
        Element.el Styles.None
            [ Attr.verticalCenter
            , Attr.center
            ]
            (shuffleDie model)


preventAddingMobster : List Mobster.Mobster -> String -> Bool
preventAddingMobster mobsters newMobster =
    mobsters |> List.map (.name >> String.toLower) |> List.member (newMobster |> String.toLower |> String.trim)
