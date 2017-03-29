module Setup.Rpg.View exposing (RpgState(..), rpgView)

import Basics.Extra exposing ((=>))
import Html exposing (..)
import Html.Keyed
import Html.Attributes as Attr exposing (href, id, placeholder, src, style, target, title, type_, value)
import Html.CssHelpers
import Html.Events exposing (keyCode, on, onCheck, onClick, onDoubleClick, onInput, onSubmit)
import List.Extra
import Mobster.Data exposing (..)
import Mobster.Rpg as Rpg exposing (RpgData)
import Mobster.RpgPresenter
import Setup.Msg exposing (..)
import Setup.RpgIcons
import Setup.Stylesheet exposing (CssClasses(..))
import Mobster.Operation as MobsterOperation exposing (MobsterOperation)


type RpgState
    = Checklist
    | NextUp


noTabThingy : Attribute msg
noTabThingy =
    Attr.tabindex -1


{ id, class, classList } =
    Html.CssHelpers.withNamespace "setup"



-- rpgView : RpgState -> a -> Html Msg


rpgView :
    RpgState
    -> { e
        | intervalsSinceBreak : a
        , onMac : b
        , secondsSinceBreak : c
        , settings : { d | mobsterData : MobsterData }
       }
    -> Html Msg
rpgView rpgState ({ onMac, secondsSinceBreak, intervalsSinceBreak, settings } as model) =
    let
        rpgButton =
            case rpgState of
                Checklist ->
                    button
                        [ noTabThingy
                        , onClick ViewRpgNextUp
                        , Attr.class "btn btn-info btn-lg btn-block"
                        , class [ BufferTop, TooltipContainer ]
                        , class [ LargeButtonText ]
                        ]
                        [ text "See Next Up" ]

                NextUp ->
                    button
                        [ noTabThingy
                        , onClick StartTimer
                        , Attr.class "btn btn-info btn-lg btn-block"
                        , class [ BufferTop, TooltipContainer ]
                        , class [ LargeButtonText ]
                        ]
                        [ text "Start Mobbing" ]
    in
        div [ Attr.class "container-fluid" ]
            [ -- breakView secondsSinceBreak intervalsSinceBreak settings.intervalsPerBreak,
              rpgRolesView settings.mobsterData
            , div [ Attr.class "row", style [ "padding-bottom" => "1.333em" ] ]
                [ rpgButton ]
            , div [] [ allBadgesView settings.mobsterData ]
            ]


allBadgesView : Mobster.Data.MobsterData -> Html Msg
allBadgesView mobsterData =
    div [] (List.map mobsterBadgesView mobsterData.mobsters)


mobsterBadgesView : Mobster.Data.Mobster -> Html Msg
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
                ([ span [] [ text mobster.name ] ]
                    ++ (badges |> List.map (Setup.RpgIcons.mobsterIcon))
                )


rpgRolesView : MobsterData -> Html Msg
rpgRolesView mobsterData =
    let
        ( row1, row2 ) =
            List.Extra.splitAt 2 (mobsterData |> Mobster.RpgPresenter.present)
    in
        div [] [ rpgRolesRow row1, rpgRolesRow row2 ]


rpgRolesRow : List Mobster.RpgPresenter.RpgMobster -> Html Msg
rpgRolesRow rpgMobsters =
    div [ Attr.class "row" ] (List.map rpgRoleView rpgMobsters)


rpgRoleView : Mobster.RpgPresenter.RpgMobster -> Html Msg
rpgRoleView mobster =
    div [ Attr.class "col-md-6" ] [ rpgCardView mobster ]


rpgCardView : Mobster.RpgPresenter.RpgMobster -> Html Msg
rpgCardView mobster =
    let
        roleName =
            toString mobster.role

        iconDiv =
            span [ class [ BufferRight ] ] [ Setup.RpgIcons.mobsterIcon mobster.role ]

        header =
            div [ Attr.class "h1" ] [ iconDiv, text (roleName ++ " ( " ++ mobster.name ++ ")") ]
    in
        div [] [ header, experienceView mobster ]


goalView : Mobster.RpgPresenter.RpgMobster -> Int -> Rpg.Goal -> ( String, Html Msg )
goalView mobster goalIndex goal =
    let
        nameWithoutWhitespace =
            mobster.name |> String.words |> String.join ""

        uniqueId =
            nameWithoutWhitespace ++ toString mobster.role ++ toString goalIndex
    in
        ( uniqueId
        , li [ Attr.class "checkbox checkbox-success", onCheck (CheckRpgBox (UpdateMobsterData (MobsterOperation.CompleteGoal mobster.index mobster.role goalIndex))) ]
            [ input [ Attr.id uniqueId, type_ "checkbox", Attr.checked goal.complete ] []
            , label [ Attr.for uniqueId ] [ text goal.description ]
            ]
        )


experienceView : Mobster.RpgPresenter.RpgMobster -> Html Msg
experienceView mobster =
    div [] [ Html.Keyed.ul [] (List.indexedMap (goalView mobster) mobster.experience) ]
