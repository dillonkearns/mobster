module View.RosterBeta exposing (view)

import Animation
import Animation.Messenger
import Element exposing (el)
import Element.Attributes as Attr
import Element.Events
import Json.Decode
import QuickRotate
import Roster.Data as Mobster
import Roster.Operation
import Roster.Presenter
import Roster.Rpg
import Setup.Msg as Msg exposing (..)
import Styles exposing (StyleElement)
import View.Roster


view :
    { query : String, selection : QuickRotate.Selection }
    ->
        { inactiveMobsters :
            List { name : String, rpgData : Roster.Rpg.RpgData }
        , mobsters : List Mobster.Mobster
        , nextDriver : Int
        }
    -> Animation.Messenger.State Msg.Msg
    -> Animation.State
    -> StyleElement
view quickRotateState rosterData activeMobstersStyle dieAnimation =
    Element.row Styles.None
        []
        [ rosterView quickRotateState rosterData activeMobstersStyle
        , shuffleDie dieAnimation
        ]


rosterView :
    { query : String, selection : QuickRotate.Selection }
    ->
        { inactiveMobsters :
            List { name : String, rpgData : Roster.Rpg.RpgData }
        , mobsters : List Mobster.Mobster
        , nextDriver : Int
        }
    -> Animation.Messenger.State Msg.Msg
    -> StyleElement
rosterView quickRotateState rosterData activeMobstersStyle =
    let
        inactiveMobsters =
            rosterData.inactiveMobsters

        matches =
            QuickRotate.matches (inactiveMobsters |> List.map .name) quickRotateState

        mobsters =
            Roster.Presenter.mobsters rosterData

        newMobsterDisabled =
            View.Roster.preventAddingMobster rosterData.mobsters quickRotateState.query

        inactiveTagInputHighlighted =
            case quickRotateState.selection of
                QuickRotate.Index int ->
                    True

                _ ->
                    False
    in
    Element.column Styles.None
        [ Attr.spacing 30, Attr.width (Attr.fill 1) ]
        [ Element.column Styles.None
            []
            [ el Styles.PlainBody [] <| Element.text "Active"
            , activeView quickRotateState rosterData activeMobstersStyle
            ]
        , Element.column Styles.None
            []
            [ el Styles.PlainBody [] <| Element.text "Inactive"
            , Element.wrappedRow (Styles.Roster inactiveTagInputHighlighted)
                [ Attr.width (Attr.percent 100), Attr.padding 5, Attr.spacing 10 ]
                (List.indexedMap (inactiveMobsterView quickRotateState.query quickRotateState.selection matches) (inactiveMobsters |> List.map .name))
            ]
        ]


inactiveMobsterView : String -> QuickRotate.Selection -> List Int -> Int -> String -> StyleElement
inactiveMobsterView quickRotateQuery quickRotateSelection matches mobsterIndex mobsterName =
    let
        selectionType =
            QuickRotate.selectionTypeFor mobsterIndex matches quickRotateSelection
    in
    Element.row (Styles.InactiveRosterEntry selectionType)
        [ Attr.padding 6, Attr.verticalCenter, Attr.spacing 4 ]
        [ Element.text mobsterName
        , removeButton mobsterIndex
        ]


activeView :
    { query : String, selection : QuickRotate.Selection }
    ->
        { inactiveMobsters :
            List { rpgData : Roster.Rpg.RpgData, name : String }
        , nextDriver : Int
        , mobsters : List Mobster.Mobster
        }
    -> Animation.Messenger.State Msg.Msg
    -> StyleElement
activeView quickRotateState rosterData activeMobstersStyle =
    let
        inactiveMobsters =
            rosterData.inactiveMobsters

        matches =
            QuickRotate.matches (inactiveMobsters |> List.map .name) quickRotateState

        activeMobsters =
            Roster.Presenter.mobsters rosterData

        newMobsterDisabled =
            View.Roster.preventAddingMobster rosterData.mobsters quickRotateState.query

        highlighted =
            case quickRotateState.selection of
                QuickRotate.Index int ->
                    False

                _ ->
                    True
    in
    Element.wrappedRow (Styles.Roster highlighted)
        [ Attr.width (Attr.percent 100), Attr.padding 5, Attr.spacing 10 ]
        (List.map activeMobsterView activeMobsters ++ [ rosterInput quickRotateState.query quickRotateState.selection ])


activeMobsterView : Roster.Presenter.MobsterWithRole -> StyleElement
activeMobsterView mobster =
    let
        roleIcon =
            case mobster.role of
                Just Roster.Presenter.Driver ->
                    Element.image "./assets/driver-icon.png" Styles.None [ Attr.width (Attr.px 15), Attr.height (Attr.px 15) ] Element.empty

                Just Roster.Presenter.Navigator ->
                    Element.image "./assets/navigator-icon.png" Styles.None [ Attr.width (Attr.px 15), Attr.height (Attr.px 15) ] Element.empty

                Nothing ->
                    Element.empty
    in
    Element.row (Styles.RosterEntry mobster.role)
        [ Attr.padding 6, Attr.verticalCenter, Attr.spacing 4 ]
        [ roleIcon
        , Element.text mobster.name
        , benchButton mobster.index
        ]


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
                        Ok (QuickRotateMove Previous)
                    else if code == 9 || code == 40 then
                        Ok (QuickRotateMove Next)
                    else if code == 13 then
                        Ok QuickRotateAdd
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
    Element.inputText (Styles.RosterInput highlightSelection)
        [ Attr.placeholder "+ Mobster"
        , Attr.verticalCenter
        , Attr.id quickRotateQueryId
        , Attr.height (Attr.percent 100)
        , Attr.width (Attr.fill 1)
        , Element.Events.onInput (ChangeInput (StringField QuickRotateQuery))
        , Element.Events.onWithOptions "keydown" options dec
        ]
        query


quickRotateQueryId : String
quickRotateQueryId =
    "quick-rotate-query"


benchButton : Int -> StyleElement
benchButton mobsterIndex =
    Element.el Styles.DeleteButton
        [ Element.Events.onClick (Msg.UpdateRosterData (Roster.Operation.Bench mobsterIndex))
        ]
    <|
        Element.text "×"


removeButton : Int -> StyleElement
removeButton mobsterIndex =
    Element.el Styles.DeleteButton
        [ Element.Events.onClick (Msg.UpdateRosterData (Roster.Operation.Remove mobsterIndex))
        ]
    <|
        Element.text "×"


shuffleDie :
    Animation.State
    -> StyleElement
shuffleDie animationStyle =
    Element.image "./assets/dice.png"
        Styles.ShuffleDie
        (List.map (\attr -> Attr.toAttr attr) (Animation.render animationStyle)
            ++ [ Element.Events.onClick Msg.ShuffleMobsters, Attr.height (Attr.px 25), Attr.width (Attr.px 25) ]
        )
        Element.empty
