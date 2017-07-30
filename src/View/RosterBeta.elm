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
    Element.column Styles.None
        []
        [ Element.text "Active"
        , Element.row Styles.Roster
            [ Attr.width (Attr.percent 100), Attr.padding 5, Attr.spacing 10 ]
            [ rosterItem "Uhura" Nothing
            , rosterItem "Scotty" Nothing
            , rosterItem "Kirk" (Just Roster.Presenter.Driver)
            , rosterItem "Spock" (Just Roster.Presenter.Navigator)
            , rosterInput
            ]
        , Element.text "Inactive"
        , Element.row Styles.Roster
            [ Attr.width (Attr.percent 100), Attr.padding 5, Attr.spacing 10 ]
            [ inactiveRosterItem "McCoy"
            , inactiveRosterItem "Chekov"
            , inactiveRosterItem "Sulu"
            ]
        ]


rosterInput : StyleElement
rosterInput =
    -- el Debug [] <|
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
        , Element.text (name ++ " ✖")
        ]


inactiveRosterItem : String -> StyleElement
inactiveRosterItem name =
    Element.row Styles.InactiveRosterEntry
        [ Attr.padding 6, Attr.verticalCenter, Attr.spacing 4 ]
        [ Element.text name
        , Element.text " ✖"
        ]
