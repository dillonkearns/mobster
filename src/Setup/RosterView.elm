module Setup.RosterView exposing (mobsterCellStyle, newMobsterRowView, preventAddingMobster, rotationView)

import Basics.Extra exposing ((=>))
import Html exposing (..)
import Html.Attributes as Attr exposing (href, id, placeholder, src, style, target, title, type_, value)
import Html.CssHelpers
import Html.Events exposing (keyCode, on, onCheck, onClick, onInput, onSubmit, onWithOptions)
import Html5.DragDrop as DragDrop
import Json.Decode as Decode
import List.PaddedZip
import Mobster.Data as Mobster
import Mobster.Operation as MobsterOperation exposing (MobsterOperation)
import Mobster.Presenter as Presenter
import Mobster.Rpg
import QuickRotate
import Setup.Msg exposing (..)
import Setup.Shortcuts as Shortcuts
import Setup.Stylesheet exposing (CssClasses(..))
import ViewHelpers


{ id, class, classList } =
    Html.CssHelpers.withNamespace "setup"


type alias DragDropModel =
    DragDrop.Model DragId DropArea


mobsterCellStyle : List (Attribute Msg)
mobsterCellStyle =
    [ style [ "text-align" => "right", "padding-right" => "0.667em" ] ]


mobsterCellStyle2 : Attribute Msg
mobsterCellStyle2 =
    style [ "text-align" => "right", "padding-right" => "0.667em" ]


reorderButtonView : Presenter.MobsterWithRole -> Html Msg
reorderButtonView mobster =
    let
        mobsterIndex =
            mobster.index
    in
    span []
        [ span [ Attr.class "btn-group btn-group-xs" ]
            [ button [ Attr.class "btn btn-small btn-default", onClick (UpdateMobsterData (MobsterOperation.Bench mobsterIndex)) ] [ text "x" ]
            ]
        ]


mobsterView : DragDropModel -> Bool -> Presenter.MobsterWithRole -> Html Msg
mobsterView dragDrop showHint mobster =
    let
        inactiveOverActiveStyle =
            case ( DragDrop.getDragId dragDrop, DragDrop.getDropId dragDrop ) of
                ( Just (InactiveMobster _), Just (DropActiveMobster _) ) ->
                    case mobster.role of
                        Just Presenter.Driver ->
                            True

                        _ ->
                            False

                _ ->
                    False

        isBeingDraggedOver =
            case ( DragDrop.getDragId dragDrop, DragDrop.getDropId dragDrop ) of
                ( Just (ActiveMobster _), Just (DropActiveMobster id) ) ->
                    id == mobster.index

                _ ->
                    False

        hint =
            if showHint then
                Shortcuts.numberHint mobster.index
            else
                span [] []

        displayType =
            if isBeingDraggedOver then
                "1"
            else
                "0"
    in
    td [ Attr.class "text-right col-md-6" ]
        [ span (DragDrop.draggable DragDropMsg (ActiveMobster mobster.index) ++ DragDrop.droppable DragDropMsg (DropActiveMobster mobster.index))
            [ span [ Attr.class "active-hover" ] [ span [ Attr.class "text-success fa fa-caret-right", style [ "opacity" => displayType ] ] [] ]
            , span mobsterCellStyle
                [ span [ classList [ ( DragBelow, inactiveOverActiveStyle ) ], Attr.classList [ "text-info" => (mobster.role == Just Presenter.Driver) ], Attr.class "active-mobster", onClick (UpdateMobsterData (MobsterOperation.SetNextDriver mobster.index)) ]
                    [ text mobster.name
                    , hint
                    , ViewHelpers.roleIconView mobster.role
                    ]
                ]
            , span [] [ reorderButtonView mobster ]
            ]
        ]



-- rotationView : Model -> Html Msg


rotationView model mobsterData =
    let
        mobsters =
            Presenter.mobsters mobsterData

        newMobsterDisabled =
            preventAddingMobster mobsterData.mobsters model.quickRotateState.query
    in
    div [ Attr.class "row" ]
        [ div [ Attr.class "col-md-11" ]
            [ table [ Attr.class "table h4", style [ "margin-top" => "0" ] ]
                [ tbody []
                    (inputBox model.quickRotateState newMobsterDisabled :: rosterRowsView model mobsterData)
                ]
            ]
        , div [ Attr.class "well text-center col-md-1" ]
            [ img [ onClick ShuffleMobsters, Attr.class "shuffle", src "./assets/dice.png", style [ "max-width" => "1.667em" ] ] [] ]
        ]


inputBox quickRotateState newMobsterDisabled =
    newMobsterRowView quickRotateState newMobsterDisabled


rosterRowsView model mobsterData =
    let
        inactiveMobsters =
            mobsterData.inactiveMobsters

        matches =
            QuickRotate.matches (inactiveMobsters |> List.map .name) model.quickRotateState

        mobsters =
            Presenter.mobsters mobsterData

        newMobsterDisabled =
            preventAddingMobster mobsterData.mobsters model.quickRotateState.query
    in
    List.PaddedZip.paddedZip
        (List.indexedMap (inactiveMobsterView model.quickRotateState.query model.quickRotateState.selection matches) (inactiveMobsters |> List.map .name))
        (List.map (mobsterView model.dragDrop True) mobsters)
        |> List.map (\( activeMobster, inactiveMobster ) -> tr [] [ Maybe.withDefault emptyCell inactiveMobster, Maybe.withDefault emptyCell activeMobster ])


emptyCell : Html msg
emptyCell =
    td [ Attr.class "col-md-6" ] []


preventAddingMobster : List Mobster.Mobster -> String -> Bool
preventAddingMobster mobsters newMobster =
    mobsters |> List.map (.name >> String.toLower) |> List.member (newMobster |> String.toLower |> String.trim)


newMobsterRowView : QuickRotate.State -> Bool -> Html Msg
newMobsterRowView quickRotateState newMobsterDisabled =
    let
        rowClass =
            case quickRotateState.selection of
                QuickRotate.New _ ->
                    if newMobsterDisabled then
                        "danger"
                    else
                        "success"

                _ ->
                    "active"

        displayText =
            if quickRotateState.query == "" then
                "Type a new name to add it"
            else
                quickRotateState.query
    in
    tr [ Attr.class rowClass ]
        [ td [ mobsterCellStyle2, Attr.colspan 100 ]
            [ div [ Attr.class "row" ]
                [ div [ Attr.class "col-md-10" ] [ quickRotateQueryInputView quickRotateState.query ]
                , div [ Attr.class "col-md-2" ] [ span [ Attr.class "fa fa-user-plus text-success" ] [] ]
                ]
            ]
        ]


inactiveMobsterView : String -> QuickRotate.Selection -> List Int -> Int -> String -> Html Msg
inactiveMobsterView quickRotateQuery quickRotateSelection matches mobsterIndex inactiveMobster =
    let
        isSelected =
            quickRotateSelection == QuickRotate.Index mobsterIndex

        textClasses =
            if isSelected || (isMatch && quickRotateQuery /= "") then
                "inactive-mobster selected"
            else
                "inactive-mobster"

        isMatch =
            List.member mobsterIndex matches
    in
    td
        [ Attr.class
            ((if isSelected then
                "info"
              else if isMatch && quickRotateQuery /= "" then
                "active"
              else
                ""
             )
                ++ " col-md-6"
            )
        , mobsterCellStyle2
        ]
        [ span []
            [ span [ Attr.class textClasses, onClick (UpdateMobsterData (MobsterOperation.RotateIn mobsterIndex)) ] [ text inactiveMobster ]
            , Shortcuts.letterHint mobsterIndex
            , div [ Attr.class "btn-group btn-group-xs", style [ "margin-left" => "0.667em" ] ]
                [ button [ Attr.class "btn btn-small btn-danger", onClick (UpdateMobsterData (MobsterOperation.Remove mobsterIndex)) ] [ text "x" ]
                ]
            ]
        ]


quickRotateQueryInputView : String -> Html Msg
quickRotateQueryInputView quickRotateQuery =
    let
        options =
            { preventDefault = True, stopPropagation = False }

        dec =
            Decode.map
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
                keyCode
                |> Decode.andThen
                    fromResult

        fromResult : Result String a -> Decode.Decoder a
        fromResult result =
            case result of
                Ok val ->
                    Decode.succeed val

                Err reason ->
                    Decode.fail reason
    in
    input
        [ Attr.placeholder "Filter or add mobsters"
        , type_ "text"
        , Attr.id quickRotateQueryId
        , Attr.class "form-control"
        , value quickRotateQuery
        , onWithOptions "keydown" options dec
        , onInput <| ChangeInput (StringField QuickRotateQuery)
        , style [ "font-size" => "2.0rem", "background-color" => "transparent", "color" => "white" ]
        ]
        []


quickRotateQueryId : String
quickRotateQueryId =
    "quick-rotate-query"
