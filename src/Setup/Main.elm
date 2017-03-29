port module Setup.Main exposing (..)

import Basics.Extra exposing ((=>))
import Break
import Dom
import Html exposing (..)
import Html.Attributes as Attr exposing (href, id, placeholder, src, style, target, title, type_, value)
import Html.CssHelpers
import Html.Events exposing (keyCode, on, onCheck, onClick, onDoubleClick, onInput, onSubmit)
import Html.Events.Extra exposing (onEnter)
import Html.Keyed
import Html5.DragDrop as DragDrop
import Json.Decode as Decode
import Json.Encode as Encode
import Keyboard.Combo
import List.Extra
import Mobster.Data as Mobster
import Mobster.Operation as MobsterOperation exposing (MobsterOperation)
import Mobster.Presenter as Presenter
import Mobster.Rpg as Rpg exposing (RpgData)
import Mobster.RpgPresenter
import Random
import Setup.PlotScatter
import Setup.RpgIcons
import Setup.Settings as Settings
import Setup.Shortcuts as Shortcuts exposing (hint)
import Setup.Stylesheet exposing (CssClasses(..))
import Svg
import Task
import Tip
import Update.Extra
import Setup.Msg exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace "setup"
shuffleMobstersCmd : Mobster.MobsterData -> Cmd Msg
shuffleMobstersCmd mobsterData =
    Random.generate reorderOperation (Mobster.randomizeMobsters mobsterData)


type ScreenState
    = Configure
    | Continue Bool
    | Rpg RpgState


type RpgState
    = Checklist
    | NextUp


type alias Model =
    { settings : Settings.Data
    , screenState : ScreenState
    , newMobster : String
    , combos : Keyboard.Combo.Model Msg
    , tip : Tip.Tip
    , experiment : Maybe String
    , newExperiment : String
    , ratings : List Int
    , secondsSinceBreak : Int
    , intervalsSinceBreak : Int
    , availableUpdateVersion : Maybe String
    , dragDrop : DragDropModel
    , onMac : Bool
    }


type alias DragDropModel =
    DragDrop.Model DragId DropArea


changeTip : Cmd Msg
changeTip =
    Random.generate NewTip Tip.random


initialModel : Settings.Data -> Bool -> Model
initialModel settings onMac =
    { settings = settings
    , screenState = Configure
    , newMobster = ""
    , combos = Keyboard.Combo.init ComboMsg Shortcuts.keyboardCombos
    , tip = Tip.emptyTip
    , experiment = Nothing
    , newExperiment = ""
    , ratings = []
    , secondsSinceBreak = 0
    , intervalsSinceBreak = 0
    , availableUpdateVersion = Nothing
    , dragDrop = DragDrop.init
    , onMac = onMac
    }


type alias TimerConfiguration =
    { minutes : Int, driver : String, navigator : String }


flags : Model -> TimerConfiguration
flags model =
    let
        driverNavigator =
            Presenter.nextDriverNavigator model.settings.mobsterData
    in
        { minutes = model.settings.timerDuration
        , driver = driverNavigator.driver.name
        , navigator = driverNavigator.navigator.name
        }


port startTimer : TimerConfiguration -> Cmd msg


port saveSettings : Encode.Value -> Cmd msg


port saveMobstersFile : String -> Cmd msg


port sendIpcMessage : String -> Cmd msg


port selectDuration : String -> Cmd msg


port openExternalUrl : String -> Cmd msg


port timeElapsed : (Int -> msg) -> Sub msg


port updateDownloaded : (String -> msg) -> Sub msg


port onCopyMobstersShortcut : (() -> msg) -> Sub msg


timerDurationInputView : Int -> Html Msg
timerDurationInputView duration =
    div [ Attr.class "text-primary h3 col-md-12 col-sm-6" ]
        [ input
            [ id "timer-duration"
            , onClick SelectDurationInput
            , onInput ChangeTimerDuration
            , type_ "number"
            , Attr.min (toString minTimerMinutes)
            , Attr.max (toString maxTimerMinutes)
            , value (toString duration)
            , class [ BufferRight ]
            , style [ "font-size" => "4.0rem" ]
            ]
            []
        , text "Minutes"
        ]


breakIntervalInputView : Int -> Int -> Html Msg
breakIntervalInputView intervalsPerBreak timerDuration =
    let
        theString =
            if intervalsPerBreak > 0 then
                "Break every " ++ (toString (intervalsPerBreak * timerDuration)) ++ "′"
            else
                "Breaks off"
    in
        div [ Attr.class "text-primary h3 col-md-12 col-sm-6" ]
            [ input
                [ id "break-interval"
                , onInput ChangeBreakInterval
                , type_ "number"
                , Attr.min (toString minBreakInterval)
                , Attr.max (toString maxBreakInterval)
                , value (toString intervalsPerBreak)
                , class [ BufferRight ]
                , style [ "font-size" => "4.0rem" ]
                ]
                []
            , text theString
            ]


invisibleTrigger : List (Attribute Msg) -> List (Html Msg) -> Html Msg
invisibleTrigger additionalStyles children =
    img ([ src "./assets/invisible.png", Attr.class "invisible-trigger navbar-btn", style [ "max-width" => "2.333em" ] ] ++ additionalStyles) children


ctrlKey : Bool -> String
ctrlKey onMac =
    if onMac then
        "⌘"
    else
        "Ctrl"


navbar : ScreenState -> Html Msg
navbar screen =
    let
        configureScreenButton =
            case screen of
                Configure ->
                    text ""

                Continue _ ->
                    button [ noTab, onClick OpenConfigure, Attr.class "btn btn-primary btn-sm", class [ BufferRight ] ]
                        [ span [ Attr.class "fa fa-cog" ] []
                        ]

                Rpg _ ->
                    text ""
    in
        nav [ Attr.class "navbar navbar-default navbar-fixed-top", style [ "background-color" => "rgba(0, 0, 0, 0.2)", "z-index" => "0" ] ]
            [ div [ Attr.class "container-fluid" ]
                [ div [ Attr.class "navbar-header" ]
                    [ a [ Attr.class "navbar-brand", href "#", onDoubleClick StartRpgMode ]
                        [ text "Mobster" ]
                    ]
                , div [ Attr.class "nav navbar-nav navbar-right" ]
                    [ configureScreenButton
                    , invisibleTrigger [ Attr.class "navbar-btn", class [ BufferRight ] ] []
                    , button [ noTab, onClick (SendIpcMessage Hide), Attr.class "btn btn-sm navbar-btn btn-warning", class [ BufferRight ] ]
                        [ text "Hide "
                        , span [ Attr.class "fa fa-minus-square-o" ] []
                        ]
                    , button [ noTab, onClick (SendIpcMessage Quit), Attr.class "btn btn-sm navbar-btn btn-danger", class [ BufferRight ] ]
                        [ text "Quit "
                        , span [ Attr.class "fa fa-times-circle-o" ] []
                        ]
                    ]
                ]
            ]


startMobbingShortcut : Bool -> String
startMobbingShortcut onMac =
    ((ctrlKey onMac) ++ "+Enter")


configureView : Model -> Html Msg
configureView model =
    div [ Attr.class "container-fluid" ]
        [ button
            [ noTab
            , onClick StartTimer
            , Attr.class "btn btn-info btn-lg btn-block"
            , class
                [ BufferTop
                , LargeButtonText
                , TooltipContainer
                ]
            ]
            [ text "Start Mobbing", div [ class [ Tooltip ] ] [ text (startMobbingShortcut model.onMac) ] ]
        , div [ Attr.class "row" ]
            [ div [ Attr.class "col-md-4 col-sm-12" ] [ timerDurationInputView model.settings.timerDuration, breakIntervalInputView model.settings.intervalsPerBreak model.settings.timerDuration ]
            , div [ Attr.class "col-md-4 col-sm-6" ] [ mobstersView model.newMobster (Presenter.mobsters model.settings.mobsterData) model.settings.mobsterData model.dragDrop ]
            , div [ Attr.class "col-md-4 col-sm-6" ] [ inactiveMobstersView (model.settings.mobsterData.inactiveMobsters |> List.map .name) model.dragDrop ]
            ]
        , div [ Attr.class "h1" ] [ experimentView model.newExperiment model.experiment ]
        ]


experimentView : String -> Maybe String -> Html Msg
experimentView newExperiment maybeExperiment =
    case maybeExperiment of
        Just experiment ->
            div [] [ text experiment, button [ noTab, onClick ChangeExperiment, Attr.class "btn btn-sm btn-primary" ] [ text "Edit experiment" ] ]

        Nothing ->
            div [ Attr.class "input-group" ]
                [ input [ id "add-mobster", placeholder "Try a daily experiment", type_ "text", Attr.class "form-control", value newExperiment, onInput UpdateExperimentInput, onEnter SetExperiment, style [ "font-size" => "30px" ] ] []
                , span [ Attr.class "input-group-btn", type_ "button" ] [ button [ noTab, Attr.class "btn btn-primary", onClick SetExperiment ] [ text "Set" ] ]
                ]


continueButtonChildren : Model -> List (Html Msg)
continueButtonChildren model =
    case model.experiment of
        Just experimentText ->
            [ div [ Attr.class "col-md-4" ] [ text "Continue" ]
            , div
                [ Attr.class "col-md-8"
                , style
                    [ "font-style" => "italic"
                    , "text-align" => "left"
                    ]
                ]
                [ text experimentText ]
            ]

        Nothing ->
            [ div [] [ text "Continue" ] ]


ratingsToPlotData : List Int -> List ( Float, Float )
ratingsToPlotData ratings =
    List.indexedMap (\index value -> ( toFloat index, toFloat value )) ratings


ratingsView : Model -> Svg.Svg Msg
ratingsView model =
    case model.experiment of
        Just _ ->
            if List.length model.ratings > 0 then
                Setup.PlotScatter.view (ratingsToPlotData model.ratings)
            else
                div [] []

        Nothing ->
            div [] []


breakView : Int -> Int -> Int -> Html msg
breakView secondsSinceBreak intervalsSinceBreak intervalsPerBreak =
    if intervalsPerBreak > 0 && Break.breakSuggested intervalsSinceBreak intervalsPerBreak then
        div [ Attr.class "alert alert-warning alert-dismissible", style [ "font-size" => "1.2em" ] ]
            [ span [ Attr.class "glyphicon glyphicon-exclamation-sign", class [ BufferRight ] ] []
            , text ("How about a walk? (You've been mobbing for " ++ (toString (secondsSinceBreak // 60)) ++ " minutes.)")
            ]
    else
        div [] []


viewIntervalsBeforeBreak : Model -> Html Msg
viewIntervalsBeforeBreak model =
    let
        remainingIntervals =
            Break.timersBeforeNext model.intervalsSinceBreak model.settings.intervalsPerBreak

        intervalBadges =
            List.range 1 model.settings.intervalsPerBreak
                |> List.map (\index -> index > model.intervalsSinceBreak)
                |> List.map
                    (\grayBadge ->
                        if grayBadge then
                            span [ Attr.class "label label-default" ] [ text " " ]
                        else
                            span [ Attr.class "label label-info" ] [ text " " ]
                    )
    in
        div [ onClick ResetBreakData ] intervalBadges


noTab : Attribute Msg
noTab =
    Attr.tabindex -1


rpgView : RpgState -> Model -> Html Msg
rpgView rpgState model =
    let
        rpgButton =
            case rpgState of
                Checklist ->
                    button
                        [ noTab
                        , onClick ViewRpgNextUp
                        , Attr.class "btn btn-info btn-lg btn-block"
                        , class [ BufferTop, TooltipContainer ]
                        , class [ LargeButtonText ]
                        ]
                        [ text "See Next Up", div [ class [ Tooltip ] ] [ text (startMobbingShortcut model.onMac) ] ]

                NextUp ->
                    button
                        [ noTab
                        , onClick StartTimer
                        , Attr.class "btn btn-info btn-lg btn-block"
                        , class [ BufferTop, TooltipContainer ]
                        , class [ LargeButtonText ]
                        ]
                        [ text "Start Mobbing", div [ class [ Tooltip ] ] [ text (startMobbingShortcut model.onMac) ] ]
    in
        div [ Attr.class "container-fluid" ]
            [ breakView model.secondsSinceBreak model.intervalsSinceBreak model.settings.intervalsPerBreak
            , rpgRolesView model
            , div [ Attr.class "row", style [ "padding-bottom" => "1.333em" ] ]
                [ rpgButton ]
            , div [] [ allBadgesView model ]
            ]


allBadgesView : Model -> Html Msg
allBadgesView model =
    div [] (List.map mobsterBadgesView model.settings.mobsterData.mobsters)


mobsterBadgesView : Mobster.Mobster -> Html Msg
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


continueView : Bool -> Model -> Html Msg
continueView showRotation model =
    let
        mainView =
            if showRotation then
                rotationView model
            else
                tipView model.tip
    in
        div [ Attr.class "container-fluid" ]
            [ ratingsView model
              -- , div [] [ viewIntervalsBeforeBreak model ]
            , breakView model.secondsSinceBreak model.intervalsSinceBreak model.settings.intervalsPerBreak
            , nextDriverNavigatorView model
            , div [ Attr.class "row", style [ "padding-bottom" => "1.333em" ] ]
                [ button
                    [ noTab
                    , onClick StartTimer
                    , Attr.class "btn btn-info btn-lg btn-block"
                    , class [ BufferTop, TooltipContainer ]
                    , class [ LargeButtonText ]
                    ]
                    ((continueButtonChildren model) ++ [ div [ class [ Tooltip ] ] [ text (startMobbingShortcut model.onMac) ] ])
                ]
            , mainView
            ]


tipView : Tip.Tip -> Html Msg
tipView tip =
    div [ Attr.class "jumbotron tip", style [ "margin" => "0px", "padding" => "1.667em" ] ]
        [ div [ Attr.class "row" ]
            [ h2 [ Attr.class "text-success pull-left", style [ "margin" => "0px", "padding-bottom" => "0.667em" ] ]
                [ text tip.title ]
            , a [ Attr.tabindex -1, target "_blank", Attr.class "btn btn-sm btn-primary pull-right", onClick (OpenExternalUrl tip.url) ] [ text "Learn More" ]
            ]
        , div [ Attr.class "row" ] [ Tip.tipView tip ]
        ]


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


rpgData : RpgData
rpgData =
    Rpg.init


rpgRolesView : Model -> Html Msg
rpgRolesView model =
    let
        ( row1, row2 ) =
            List.Extra.splitAt 2 (model.settings.mobsterData |> Mobster.RpgPresenter.present)
    in
        div [] [ rpgRolesRow row1, rpgRolesRow row2 ]


rpgRolesRow : List Mobster.RpgPresenter.RpgMobster -> Html Msg
rpgRolesRow rpgMobsters =
    div [ Attr.class "row" ] (List.map rpgRoleView rpgMobsters)


rpgRoleView : Mobster.RpgPresenter.RpgMobster -> Html Msg
rpgRoleView mobster =
    div [ Attr.class "col-md-6" ] [ rpgCardView mobster ]


nextDriverNavigatorView : Model -> Html Msg
nextDriverNavigatorView model =
    let
        driverNavigator =
            Presenter.nextDriverNavigator model.settings.mobsterData
    in
        div [ Attr.class "row h1 text-center", class [ ShowOnParentHoverParent ] ]
            [ dnView driverNavigator.driver Presenter.Driver
            , dnView driverNavigator.navigator Presenter.Navigator
            ]


dnView : Presenter.Mobster -> Presenter.Role -> Html Msg
dnView mobster role =
    let
        icon =
            case role of
                Presenter.Driver ->
                    "./assets/driver-icon.png"

                Presenter.Navigator ->
                    "./assets/navigator-icon.png"

        awayButton =
            span
                [ Attr.class "btn btn-sm btn-default"
                , style [ "font-size" => "23px" ]
                , class [ ShowOnParentHover, BufferRight ]
                , onClick <| UpdateMobsterData (MobsterOperation.Bench mobster.index)
                ]
                [ span [ Attr.class "fa fa-user-times text-danger", style [ "padding-right" => "4px" ] ] []
                , text " Away"
                ]

        skipButton =
            span [ Attr.class "btn btn-sm btn-default", style [ "font-size" => "23px", "padding-right" => "4px" ], class [ ShowOnParentHover ], onClick <| UpdateMobsterData MobsterOperation.NextTurn ]
                [ span [ Attr.class "fa fa-fast-forward text-warning" ] []
                , text " Skip"
                ]

        hoverButtons =
            case role of
                Presenter.Driver ->
                    [ awayButton, skipButton ]

                Presenter.Navigator ->
                    [ awayButton ]
    in
        div [ Attr.class "col-md-6 col-sm-6 text-default" ]
            [ iconView icon 60
            , span [ class [ BufferRight ] ] [ text mobster.name ]
            , span [] hoverButtons
            ]


iconView : String -> Int -> Html msg
iconView iconUrl maxWidth =
    img [ style [ "max-width" => (toString maxWidth ++ "px"), "margin-right" => "0.533em" ], src iconUrl ] []


nextView : String -> String -> Html msg
nextView thing name =
    span []
        [ span [ Attr.class "text-muted" ] [ text ("Next " ++ thing ++ ": ") ]
        , span [ Attr.class "text-info" ] [ text name ]
        ]


addMobsterInputView : String -> Mobster.MobsterData -> Html Msg
addMobsterInputView newMobster mobsterData =
    let
        hasError =
            Mobster.containsName newMobster mobsterData
    in
        div [ Attr.class "row", class [ BufferTop ] ]
            [ div [ Attr.class "input-group" ]
                [ input [ id "add-mobster", Attr.placeholder "Jane Doe", type_ "text", classList [ HasError => hasError ], Attr.class "form-control", value newMobster, onInput UpdateMobsterInput, onEnter AddMobster, style [ "font-size" => "2.0rem" ] ] []
                , span [ Attr.class "input-group-btn", type_ "button" ] [ button [ noTab, Attr.class "btn btn-primary", onClick ClickAddMobster ] [ text "Add Mobster" ] ]
                ]
            ]


mobstersView : String -> List Presenter.MobsterWithRole -> Mobster.MobsterData -> DragDropModel -> Html Msg
mobstersView newMobster mobsters mobsterData dragDrop =
    div [ style [ "padding-bottom" => "35px" ] ]
        [ addMobsterInputView newMobster mobsterData
        , img [ onClick ShuffleMobsters, Attr.class "shuffle", class [ BufferTop ], src "./assets/dice.png", style [ "max-width" => "1.667em" ] ] []
        , table [ Attr.class "table h3" ] (List.map (mobsterView dragDrop False) mobsters)
        ]


inactiveMobstersView : List String -> DragDropModel -> Html Msg
inactiveMobstersView inactiveMobsters dragDrop =
    let
        benchStyle =
            case ( DragDrop.getDragId dragDrop, DragDrop.getDropId dragDrop ) of
                ( Just (ActiveMobster _), Just DropBench ) ->
                    class [ DropAreaActive ]

                ( Just (ActiveMobster _), _ ) ->
                    class [ DropAreaInactive ]

                ( _, _ ) ->
                    class []
    in
        case ( DragDrop.getDragId dragDrop, DragDrop.getDropId dragDrop ) of
            ( Just (ActiveMobster _), _ ) ->
                div (DragDrop.droppable DragDropMsg DropBench ++ [ benchStyle, style [ "height" => "150px" ] ]) [ text "Move to bench" ]

            ( _, _ ) ->
                div (DragDrop.droppable DragDropMsg DropBench ++ [ benchStyle ])
                    [ h2 [ Attr.class "text-center text-primary" ] [ text "Bench" ]
                    , table [ Attr.class "table h3" ] (List.indexedMap inactiveMobsterView inactiveMobsters)
                    ]


mobsterCellStyle : List (Attribute Msg)
mobsterCellStyle =
    [ style [ "text-align" => "right", "padding-right" => "0.667em" ] ]


numberHint : Int -> Html msg
numberHint index =
    let
        maybeHint =
            if index == 9 then
                Just 0
            else if index < 9 then
                Just (index + 1)
            else
                Nothing
    in
        case maybeHint of
            Just hintText ->
                span [ style [ "font-size" => "0.7em", "color" => "grey" ] ] [ text (" (" ++ toString hintText ++ ")") ]

            Nothing ->
                span [] []


inactiveMobsterViewWithHints : Int -> String -> Html Msg
inactiveMobsterViewWithHints mobsterIndex inactiveMobster =
    tr []
        [ td mobsterCellStyle
            [ span [ Attr.class "inactive-mobster", onClick (UpdateMobsterData (MobsterOperation.RotateIn mobsterIndex)) ] [ text inactiveMobster ]
            , Shortcuts.hint mobsterIndex
            ]
        ]


inactiveMobsterView : Int -> String -> Html Msg
inactiveMobsterView mobsterIndex inactiveMobster =
    tr []
        [ td (mobsterCellStyle ++ (DragDrop.draggable DragDropMsg (InactiveMobster mobsterIndex)))
            [ span [ Attr.class "inactive-mobster", onClick (UpdateMobsterData (MobsterOperation.RotateIn mobsterIndex)) ] [ text inactiveMobster ]
            , div [ Attr.class "btn-group btn-group-xs", style [ "margin-left" => "0.667em" ] ]
                [ button [ noTab, Attr.class "btn btn-small btn-danger", onClick (UpdateMobsterData (MobsterOperation.Remove mobsterIndex)) ] [ text "x" ]
                ]
            ]
        ]


mobsterView : DragDropModel -> Bool -> Presenter.MobsterWithRole -> Html Msg
mobsterView dragDrop showHint mobster =
    let
        inactiveOverActiveStyle =
            case ( DragDrop.getDragId dragDrop, DragDrop.getDropId dragDrop ) of
                ( Just (InactiveMobster _), Just (DropActiveMobster _) ) ->
                    case mobster.role of
                        Just (Presenter.Driver) ->
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

        hoverText =
            if isBeingDraggedOver then
                ">"
            else
                " "

        hint =
            if showHint then
                numberHint mobster.index
            else
                span [] []
    in
        tr
            (DragDrop.draggable DragDropMsg (ActiveMobster mobster.index) ++ DragDrop.droppable DragDropMsg (DropActiveMobster mobster.index))
            [ td [ Attr.class "active-hover" ] [ span [ Attr.class "text-success" ] [ text hoverText ] ]
            , td mobsterCellStyle
                [ span [ classList [ ( DragBelow, inactiveOverActiveStyle ) ], Attr.classList [ "text-info" => (mobster.role == Just Presenter.Driver) ], Attr.class "active-mobster", onClick (UpdateMobsterData (MobsterOperation.SetNextDriver mobster.index)) ]
                    [ text mobster.name
                    , hint
                    , roleView mobster.role
                    ]
                ]
            , td [] [ reorderButtonView mobster ]
            ]


roleView : Maybe Presenter.Role -> Html Msg
roleView role =
    case role of
        Just (Presenter.Driver) ->
            span [ Attr.class "role-icon driver-icon" ] []

        Just (Presenter.Navigator) ->
            span [ Attr.class "role-icon navigator-icon" ] []

        Nothing ->
            span [ Attr.class "role-icon no-role-icon" ] []


reorderButtonView : Presenter.MobsterWithRole -> Html Msg
reorderButtonView mobster =
    let
        mobsterIndex =
            mobster.index
    in
        div []
            [ div [ Attr.class "btn-group btn-group-xs" ]
                [ button [ noTab, Attr.class "btn btn-small btn-default", onClick (UpdateMobsterData (MobsterOperation.Bench mobsterIndex)) ] [ text "x" ]
                ]
            ]


updateAvailableView : Maybe String -> Html Msg
updateAvailableView availableUpdateVersion =
    case availableUpdateVersion of
        Nothing ->
            div [] []

        Just version ->
            div [ Attr.class "alert alert-success" ]
                [ span [ Attr.class "glyphicon glyphicon-flag", class [ BufferRight ] ] []
                , text ("A new version is downloaded and ready to install. ")
                , a [ onClick (SendIpcMessage QuitAndInstall), Attr.href "#", Attr.class "alert-link" ] [ text "Update now" ]
                , text "."
                ]


rotationView : Model -> Html Msg
rotationView model =
    let
        mobsters =
            Presenter.mobsters model.settings.mobsterData

        inactiveMobsters =
            model.settings.mobsterData.inactiveMobsters
    in
        div [ Attr.class "row" ]
            [ div [ Attr.class "col-md-6" ] [ table [ Attr.class "table h4" ] (List.map (mobsterView model.dragDrop True) mobsters) ]
            , div [ Attr.class "col-md-6" ] [ table [ Attr.class "table h4" ] (List.indexedMap inactiveMobsterViewWithHints (inactiveMobsters |> List.map .name)) ]
            ]


feedbackButton : Html Msg
feedbackButton =
    div []
        [ a [ onClick (SendIpcMessage ShowFeedbackForm), style [ "text-transform" => "uppercase", "transform" => "rotate(-90deg)" ], Attr.tabindex -1, Attr.class "btn btn-sm btn-default pull-right", Attr.id "feedback" ] [ span [ class [ BufferRight ] ] [ text "Feedback" ], span [ Attr.class "fa fa-comment-o" ] [] ] ]


view : Model -> Html Msg
view model =
    let
        mainView =
            case model.screenState of
                Configure ->
                    configureView model

                Continue showRotation ->
                    continueView showRotation model

                Rpg rpgState ->
                    rpgView rpgState model
    in
        div [] [ navbar model.screenState, updateAvailableView model.availableUpdateVersion, mainView, feedbackButton ]


resetBreakData : Model -> Model
resetBreakData model =
    { model | secondsSinceBreak = 0, intervalsSinceBreak = 0 }


resetIfAfterBreak : Model -> Model
resetIfAfterBreak model =
    let
        timeForBreak =
            Break.breakSuggested model.intervalsSinceBreak model.settings.intervalsPerBreak
    in
        if timeForBreak then
            model |> resetBreakData
        else
            model


saveActiveMobstersCmd : Model -> Cmd msg
saveActiveMobstersCmd model =
    saveMobstersFile (Mobster.currentMobsterNames model.settings.mobsterData)


saveActiveMobsters : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
saveActiveMobsters ( model, cmd ) =
    model ! [ cmd, saveActiveMobstersCmd model ]


updateSettings : (Settings.Data -> Settings.Data) -> Model -> ( Model, Cmd Msg )
updateSettings settingsUpdater ({ settings } as model) =
    let
        updatedSettings =
            settingsUpdater settings
    in
        { model | settings = updatedSettings } ! [ saveSettings (updatedSettings |> Settings.encoder) ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SkipHotkey ->
            case model.screenState of
                Continue showRotation ->
                    update (UpdateMobsterData MobsterOperation.NextTurn) model

                _ ->
                    model ! []

        StartRpgMode ->
            { model | screenState = Rpg NextUp } ! []

        ShowRotationScreen ->
            case model.screenState of
                Continue showRotation ->
                    { model | screenState = Continue (not showRotation) } ! []

                _ ->
                    model ! []

        StartTimer ->
            let
                nextScreenState =
                    case model.screenState of
                        Rpg rpgState ->
                            Rpg Checklist

                        _ ->
                            Continue False

                updatedModel =
                    { model | screenState = nextScreenState }
                        |> resetIfAfterBreak
            in
                updatedModel
                    ! [ (startTimer (flags model)), changeTip ]
                    |> Update.Extra.andThen update (UpdateMobsterData MobsterOperation.NextTurn)

        ChangeTimerDuration newDurationAsString ->
            model
                |> updateSettings
                    (\settings -> { settings | timerDuration = (validateTimerDuration newDurationAsString settings.timerDuration) })

        ChangeBreakInterval newIntervalAsString ->
            model
                |> updateSettings
                    (\settings ->
                        { settings
                            | intervalsPerBreak = (validateBreakInterval newIntervalAsString settings.intervalsPerBreak)
                        }
                    )

        SelectDurationInput ->
            model ! [ selectDuration "timer-duration" ]

        OpenConfigure ->
            { model | screenState = Configure } ! []

        AddMobster ->
            if model.newMobster == "" || Mobster.containsName model.newMobster model.settings.mobsterData then
                model ! []
            else
                update (UpdateMobsterData (MobsterOperation.Add model.newMobster)) { model | newMobster = "" }

        ClickAddMobster ->
            if model.newMobster == "" then
                model ! [ focusAddMobsterInput ]
            else
                { model | newMobster = "" }
                    ! [ focusAddMobsterInput ]
                    |> Update.Extra.andThen update (UpdateMobsterData (MobsterOperation.Add model.newMobster))

        DomFocusResult _ ->
            model ! []

        UpdateMobsterData operation ->
            model
                |> updateSettings
                    (\settings -> { settings | mobsterData = MobsterOperation.updateMoblist operation model.settings.mobsterData })
                |> saveActiveMobsters

        UpdateMobsterInput text ->
            { model | newMobster = text } ! []

        ComboMsg msg ->
            let
                updatedCombos =
                    Keyboard.Combo.update msg model.combos
            in
                { model | combos = updatedCombos } ! []

        NewTip tipIndex ->
            { model | tip = (Tip.get tipIndex) } ! []

        SetExperiment ->
            if model.newExperiment == "" then
                model ! []
            else
                { model | experiment = Just model.newExperiment } ! []

        UpdateExperimentInput newExperiment ->
            { model | newExperiment = newExperiment } ! []

        ChangeExperiment ->
            { model | experiment = Nothing } ! []

        EnterRating rating ->
            update StartTimer { model | ratings = model.ratings ++ [ rating ] }

        ShuffleMobsters ->
            model ! [ shuffleMobstersCmd model.settings.mobsterData ]

        TimeElapsed elapsedSeconds ->
            { model | secondsSinceBreak = (model.secondsSinceBreak + elapsedSeconds), intervalsSinceBreak = model.intervalsSinceBreak + 1 } ! []

        ResetBreakData ->
            (model |> resetBreakData) ! []

        UpdateAvailable availableUpdateVersion ->
            { model | availableUpdateVersion = Just availableUpdateVersion } ! []

        RotateOutHotkey index ->
            if model.screenState == (Continue True) then
                update (UpdateMobsterData (MobsterOperation.Bench index)) model
            else
                model ! []

        RotateInHotkey index ->
            if model.screenState == (Continue True) then
                update (UpdateMobsterData (MobsterOperation.RotateIn index)) model
            else
                model ! []

        DragDropMsg dragDropMsg ->
            let
                ( updatedDragDrop, dragDropResult ) =
                    DragDrop.update dragDropMsg model.dragDrop

                updatedModel =
                    { model | dragDrop = updatedDragDrop }
            in
                case dragDropResult of
                    Nothing ->
                        updatedModel ! []

                    Just ( dragId, dropId ) ->
                        case ( dragId, dropId ) of
                            ( ActiveMobster id, DropActiveMobster actualDropid ) ->
                                update (UpdateMobsterData (MobsterOperation.Move id actualDropid)) updatedModel

                            ( ActiveMobster id, DropBench ) ->
                                update (UpdateMobsterData (MobsterOperation.Bench id)) updatedModel

                            ( InactiveMobster inactiveMobsterId, DropActiveMobster activeMobsterId ) ->
                                update (UpdateMobsterData (MobsterOperation.RotateIn inactiveMobsterId)) updatedModel

                            _ ->
                                model ! []

        SendIpcMessage ipcMessage ->
            model ! [ sendIpcMessage (toString ipcMessage) ]

        OpenExternalUrl url ->
            model
                ! [ openExternalUrl url ]
                |> Update.Extra.andThen update (SendIpcMessage Hide)

        CheckRpgBox msg checkedValue ->
            update msg model

        ViewRpgNextUp ->
            { model | screenState = Rpg NextUp }
                ! []
                |> Update.Extra.andThen update
                    (UpdateMobsterData MobsterOperation.NextTurn)


reorderOperation : List Mobster.Mobster -> Msg
reorderOperation shuffledMobsters =
    (UpdateMobsterData (MobsterOperation.Reorder shuffledMobsters))


focusAddMobsterInput : Cmd Msg
focusAddMobsterInput =
    Task.attempt DomFocusResult (Dom.focus "add-mobster")


minTimerMinutes : Int
minTimerMinutes =
    1


maxTimerMinutes : Int
maxTimerMinutes =
    120


validateTimerDuration : String -> Int -> Int
validateTimerDuration newDurationAsString oldTimerDuration =
    let
        rawDuration =
            Result.withDefault 5 (String.toInt newDurationAsString)
    in
        if rawDuration > maxTimerMinutes then
            maxTimerMinutes
        else if rawDuration < minTimerMinutes then
            minTimerMinutes
        else
            rawDuration


validateBreakInterval : String -> Int -> Int
validateBreakInterval newDurationAsString oldTimerDuration =
    let
        rawDuration =
            Result.withDefault 6 (String.toInt newDurationAsString)
    in
        if rawDuration > maxBreakInterval then
            maxBreakInterval
        else if rawDuration < minBreakInterval then
            minBreakInterval
        else
            rawDuration


maxBreakInterval : Int
maxBreakInterval =
    120


minBreakInterval : Int
minBreakInterval =
    0


init : { onMac : Bool, settings : Decode.Value } -> ( Model, Cmd Msg )
init { onMac, settings } =
    let
        decodedSettings =
            Settings.decode settings

        initialSettings =
            case decodedSettings of
                Ok settings ->
                    settings

                Err errorString ->
                    let
                        _ =
                            Debug.log "init failed to decode settings" errorString
                    in
                        Settings.initial
    in
        initialModel initialSettings onMac ! [] |> saveActiveMobsters


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Keyboard.Combo.subscriptions model.combos
        , timeElapsed TimeElapsed
        , updateDownloaded UpdateAvailable
        ]


main : Program { onMac : Bool, settings : Decode.Value } Model Msg
main =
    Html.programWithFlags
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
