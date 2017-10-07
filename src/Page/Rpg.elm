module Page.Rpg exposing (view)

-- import StylesheetHelper exposing (CssClasses(..), class)

import Element
import Element.Attributes as Attr
import Html exposing (Html, button, div, input, label, li, span, text)
import Html.Attributes exposing (style, type_)
import Html.Events
import Html.Keyed
import List.Extra
import Os exposing (Os)
import Roster.Data exposing (RosterData)
import Roster.Rpg as Rpg
import Roster.RpgPresenter
import Setup.Msg as Msg exposing (Msg)
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
    , div [] [ allBadgesView rosterData ] |> Element.html
    ]


allBadgesView : Roster.Data.RosterData -> Html Msg
allBadgesView rosterData =
    div [] (List.map mobsterBadgesView rosterData.mobsters)


mobsterBadgesView : Roster.Data.Mobster -> Html Msg
mobsterBadgesView mobster =
    let
        badges =
            mobster.rpgData
                |> Rpg.badges
    in
    if List.length badges == 0 then
        span [] []
    else
        span []
            (span [] [ text mobster.name ]
                :: (badges |> List.map Setup.RpgIcons.mobsterIcon)
            )


rpgRolesView : RosterData -> Styles.StyleElement
rpgRolesView rosterData =
    let
        ( row1, row2 ) =
            List.Extra.splitAt 2 (rosterData |> Roster.RpgPresenter.present)
    in
    -- div [] [
    --
    -- rpgCardView row1, rpgCardView row2
    -- ]
    Element.column Styles.None [] [ rpgRolesRow row1, rpgRolesRow row2 ]


rpgRolesRow : List Roster.RpgPresenter.RpgMobster -> Styles.StyleElement
rpgRolesRow rpgMobsters =
    Element.row Styles.None [] (List.map rpgCardView rpgMobsters)


rpgCardView : Roster.RpgPresenter.RpgMobster -> Styles.StyleElement
rpgCardView mobster =
    let
        roleName =
            toString mobster.role

        iconDiv =
            -- span [ class [ BufferRight ] ] [ Setup.RpgIcons.mobsterIcon mobster.role ]
            Setup.RpgIcons.mobsterIcon mobster.role
                |> Element.html

        header =
            Element.row Styles.None [] [ iconDiv, Element.text (roleName ++ " ( " ++ mobster.name ++ ")") ]
    in
    Element.column Styles.None [ Attr.width Attr.fill ] [ header, experienceView mobster |> Element.html ]


goalView : Roster.RpgPresenter.RpgMobster -> Int -> Rpg.Goal -> ( String, Html Msg )
goalView mobster goalIndex goal =
    let
        nameWithoutWhitespace =
            mobster.name |> String.words |> String.join ""

        uniqueId =
            nameWithoutWhitespace ++ toString mobster.role ++ toString goalIndex
    in
    ( uniqueId
    , li
        [ Html.Events.onClick (Msg.CheckRpgBox { index = mobster.index, role = mobster.role } goalIndex)
        ]
        [ text (toString goal.complete)
        , label [ Html.Attributes.for uniqueId ] [ text goal.description ]
        ]
    )


experienceView : Roster.RpgPresenter.RpgMobster -> Html Msg
experienceView mobster =
    div [] [ Html.Keyed.ul [] (List.indexedMap (goalView mobster) mobster.experience) ]
