module View.RosterBeta exposing (view)

import Animation.Messenger
import Element
import Element.Attributes as Attr
import QuickRotate
import Roster.Data as Mobster
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
    -> StyleElement
view quickRotateState rosterData activeMobstersStyle =
    let
        inactiveMobsters =
            rosterData.inactiveMobsters

        matches =
            QuickRotate.matches (inactiveMobsters |> List.map .name) quickRotateState

        mobsters =
            Roster.Presenter.mobsters rosterData

        newMobsterDisabled =
            View.Roster.preventAddingMobster rosterData.mobsters quickRotateState.query
    in
    Element.column Styles.None
        []
        [ Element.text "Active"
        , activeView quickRotateState rosterData activeMobstersStyle
        , Element.text "Inactive"
        , Element.row Styles.Roster
            [ Attr.width (Attr.percent 100), Attr.padding 5, Attr.spacing 10 ]
            (List.indexedMap (inactiveMobsterView quickRotateState.query quickRotateState.selection matches) (inactiveMobsters |> List.map .name))
        ]


inactiveMobsterView : String -> QuickRotate.Selection -> List Int -> Int -> String -> StyleElement
inactiveMobsterView quickRotateQuery quickRotateSelection matches mobsterIndex inactiveMobster =
    inactiveRosterItem inactiveMobster


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
    in
    Element.row Styles.Roster
        [ Attr.width (Attr.percent 100), Attr.padding 5, Attr.spacing 10 ]
        (List.map activeMobsterView activeMobsters)


activeMobsterView : Roster.Presenter.MobsterWithRole -> StyleElement
activeMobsterView mobster =
    rosterItem mobster.name mobster.role


rosterInput : StyleElement
rosterInput =
    Element.inputText Styles.RosterInput [ Attr.placeholder "+ Mobster", Attr.verticalCenter, Attr.height (Attr.percent 100), Attr.width (Attr.fill 1) ] ""


rosterItem : String -> Maybe Roster.Presenter.Role -> StyleElement
rosterItem name entryType =
    let
        roleIcon =
            case entryType of
                Just Roster.Presenter.Driver ->
                    Element.image "./assets/driver-icon.png" Styles.None [ Attr.width (Attr.px 15), Attr.height (Attr.px 15) ] Element.empty

                Just Roster.Presenter.Navigator ->
                    Element.image "./assets/navigator-icon.png" Styles.None [ Attr.width (Attr.px 15), Attr.height (Attr.px 15) ] Element.empty

                Nothing ->
                    Element.empty
    in
    Element.row (Styles.RosterEntry entryType)
        [ Attr.padding 6, Attr.verticalCenter, Attr.spacing 4 ]
        [ roleIcon
        , Element.text (name ++ " ×")
        ]


inactiveRosterItem : String -> StyleElement
inactiveRosterItem name =
    Element.row Styles.InactiveRosterEntry
        [ Attr.padding 6, Attr.verticalCenter, Attr.spacing 4 ]
        [ Element.text name
        , Element.text " ×"
        ]
