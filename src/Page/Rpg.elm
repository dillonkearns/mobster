module Page.Rpg exposing (view)

import Element
import Element.Attributes as Attr
import Element.Events
import Element.Keyed
import List.Extra
import Os exposing (Os)
import Roster.Data exposing (RosterData)
import Roster.Rpg as Rpg
import Roster.RpgPresenter
import Setup.Msg as Msg
import Setup.RpgIcons
import Setup.ScreenState as ScreenState
import Styles
import View.StartMobbingButton


view : { model | os : Os, device : Element.Device } -> ScreenState.RpgState -> RosterData -> List Styles.StyleElement
view model rpgState rosterData =
    let
        rpgButton =
            case rpgState of
                ScreenState.Checklist ->
                    View.StartMobbingButton.viewWithMsg model "See Next Up" Msg.ViewRpgNextUp

                ScreenState.NextUp ->
                    View.StartMobbingButton.viewWithMsg model "Start Mobbing" Msg.StartTimer
    in
    [ rpgRolesView rosterData
    , rpgButton
    , allBadgesView rosterData
    ]


allBadgesView : Roster.Data.RosterData -> Styles.StyleElement
allBadgesView rosterData =
    Element.row Styles.None [] (List.map mobsterBadgesView rosterData.mobsters)


mobsterBadgesView : Roster.Data.Mobster -> Styles.StyleElement
mobsterBadgesView mobster =
    let
        badges =
            mobster.rpgData
                |> Rpg.badges
    in
    if List.length badges == 0 then
        Element.empty
    else
        Element.row Styles.None
            []
            (Element.text mobster.name
                :: (badges
                        |> List.map Setup.RpgIcons.mobsterIcon
                        |> List.map Element.html
                   )
            )


rpgRolesView : RosterData -> Styles.StyleElement
rpgRolesView rosterData =
    let
        ( row1, row2 ) =
            List.Extra.splitAt 2 (rosterData |> Roster.RpgPresenter.present)
    in
    Element.column Styles.None [ Attr.spacing 80 ] [ rpgRolesRow row1, rpgRolesRow row2 ]


rpgRolesRow : List Roster.RpgPresenter.RpgMobster -> Styles.StyleElement
rpgRolesRow rpgMobsters =
    Element.row Styles.None [] (List.map rpgCardView rpgMobsters)


rpgCardView : Roster.RpgPresenter.RpgMobster -> Styles.StyleElement
rpgCardView mobster =
    let
        roleName =
            toString mobster.role

        iconDiv =
            Setup.RpgIcons.mobsterIcon mobster.role
                |> Element.html

        header =
            Element.row Styles.None [] [ iconDiv, Element.text (roleName ++ " ( " ++ mobster.name ++ ")") ]
    in
    Element.column Styles.None [ Attr.width (Attr.fillPortion 1) ] [ header, experienceView mobster ]


goalView : Roster.RpgPresenter.RpgMobster -> Int -> Rpg.Goal -> ( String, Styles.StyleElement )
goalView mobster goalIndex goal =
    let
        nameWithoutWhitespace =
            mobster.name |> String.words |> String.join ""

        uniqueId =
            nameWithoutWhitespace ++ toString mobster.role ++ toString goalIndex
    in
    ( uniqueId
    , Element.row
        Styles.None
        [ Element.Events.onClick (Msg.CheckRpgBox { index = mobster.index, role = mobster.role } goalIndex) ]
        [ Element.text (toString goal.complete)
        , Element.paragraph Styles.None [] [ Element.text goal.description ]
        ]
    )


experienceView : Roster.RpgPresenter.RpgMobster -> Styles.StyleElement
experienceView mobster =
    Element.Keyed.column Styles.None
        []
        (List.indexedMap (goalView mobster) mobster.experience)
