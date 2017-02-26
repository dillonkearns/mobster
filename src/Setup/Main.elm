port module Setup.Main exposing (..)

import Html exposing (..)
import Html.Attributes as Attr exposing (value, type_, id, style, src, title, href, target, placeholder)
import Html.Events exposing (on, keyCode, onClick, onInput, onSubmit)
import Html.Events.Extra exposing (onEnter)
import Json.Decode as Json
import Task
import Dom
import Mobster exposing (MobsterOperation)
import Json.Decode as Decode
import Keyboard.Combo
import Random
import Tip
import Setup.PlotScatter
import Svg
import Update.Extra
import Html.CssHelpers
import Setup.Stylesheet exposing (CssClasses(..))
import Array
import Break
import Setup.Settings as Settings
import Html5.DragDrop as DragDrop


{ id, class, classList } =
    Html.CssHelpers.withNamespace "setup"
shuffleMobstersCmd : Mobster.MobsterData -> Cmd Msg
shuffleMobstersCmd mobsterData =
    Random.generate reorderOperation (Mobster.randomizeMobsters mobsterData)


type Msg
    = StartTimer
    | ShowRotationScreen
    | SkipHotkey
    | UpdateMobsterData MobsterOperation
    | UpdateMobsterInput String
    | AddMobster
    | ClickAddMobster
    | DomFocusResult (Result Dom.Error ())
    | ChangeTimerDuration String
    | ChangeBreakInterval String
    | SelectDurationInput
    | OpenConfigure
    | NewTip Int
    | SetExperiment
    | ChangeExperiment
    | UpdateExperimentInput String
    | EnterRating Int
    | Quit
    | QuitAndInstall
    | ComboMsg Keyboard.Combo.Msg
    | ShuffleMobsters
    | TimeElapsed Int
    | UpdateAvailable String
    | CopyActiveMobsters ()
    | ResetBreakData
    | RotateInHotkey Int
    | DragDropMsg (DragDrop.Msg DragId DropArea)


type DragId
    = ActiveMobster Int
    | InactiveMobster Int


type DropArea
    = DropBench
    | DropActiveMobster Int


keyboardCombos : List (Keyboard.Combo.KeyCombo Msg)
keyboardCombos =
    [ Keyboard.Combo.combo2 ( Keyboard.Combo.control, Keyboard.Combo.enter ) StartTimer
    , Keyboard.Combo.combo2 ( Keyboard.Combo.command, Keyboard.Combo.enter ) StartTimer
    , Keyboard.Combo.combo2 ( Keyboard.Combo.shift, Keyboard.Combo.one ) (EnterRating 1)
    , Keyboard.Combo.combo2 ( Keyboard.Combo.shift, Keyboard.Combo.two ) (EnterRating 2)
    , Keyboard.Combo.combo2 ( Keyboard.Combo.shift, Keyboard.Combo.three ) (EnterRating 3)
    , Keyboard.Combo.combo1 Keyboard.Combo.r (ShowRotationScreen)
    , Keyboard.Combo.combo1 Keyboard.Combo.s (SkipHotkey)
    , Keyboard.Combo.combo1 Keyboard.Combo.a (RotateInHotkey 0)
    , Keyboard.Combo.combo1 Keyboard.Combo.b (RotateInHotkey 1)
    , Keyboard.Combo.combo1 Keyboard.Combo.c (RotateInHotkey 2)
    , Keyboard.Combo.combo1 Keyboard.Combo.d (RotateInHotkey 3)
    , Keyboard.Combo.combo1 Keyboard.Combo.e (RotateInHotkey 4)
    , Keyboard.Combo.combo1 Keyboard.Combo.f (RotateInHotkey 5)
    , Keyboard.Combo.combo1 Keyboard.Combo.g (RotateInHotkey 6)
    , Keyboard.Combo.combo1 Keyboard.Combo.h (RotateInHotkey 7)
    , Keyboard.Combo.combo1 Keyboard.Combo.i (RotateInHotkey 8)
    , Keyboard.Combo.combo1 Keyboard.Combo.j (RotateInHotkey 9)
    , Keyboard.Combo.combo1 Keyboard.Combo.k (RotateInHotkey 10)
    , Keyboard.Combo.combo1 Keyboard.Combo.l (RotateInHotkey 11)
    , Keyboard.Combo.combo1 Keyboard.Combo.m (RotateInHotkey 12)
    , Keyboard.Combo.combo1 Keyboard.Combo.n (RotateInHotkey 13)
    , Keyboard.Combo.combo1 Keyboard.Combo.o (RotateInHotkey 14)
    , Keyboard.Combo.combo1 Keyboard.Combo.p (RotateInHotkey 15)
    ]


type ScreenState
    = Configure
    | Continue Bool


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
    }


type alias DragDropModel =
    DragDrop.Model DragId DropArea


changeTip : Cmd Msg
changeTip =
    Random.generate NewTip Tip.random


initialModel : Settings.Data -> Model
initialModel settings =
    { settings = settings
    , screenState = Configure
    , newMobster = ""
    , combos = Keyboard.Combo.init ComboMsg keyboardCombos
    , tip = Tip.emptyTip
    , experiment = Nothing
    , newExperiment = ""
    , ratings = []
    , secondsSinceBreak = 0
    , intervalsSinceBreak = 0
    , availableUpdateVersion = Nothing
    , dragDrop = DragDrop.init
    }


type alias TimerConfiguration =
    { minutes : Int, driver : String, navigator : String }


flags : Model -> TimerConfiguration
flags model =
    let
        driverNavigator =
            Mobster.nextDriverNavigator model.settings.mobsterData
    in
        { minutes = model.settings.timerDuration
        , driver = driverNavigator.driver.name
        , navigator = driverNavigator.navigator.name
        }


port startTimer : TimerConfiguration -> Cmd msg


port saveSettings : Settings.Data -> Cmd msg


port quit : () -> Cmd msg


port quitAndInstall : () -> Cmd msg


port selectDuration : String -> Cmd msg


port copyActiveMobsters : String -> Cmd msg


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
            , Attr.min "1"
            , Attr.max "15"
            , value (toString duration)
            , class [ BufferRight ]
            , style [ ( "font-size", "4.0rem" ) ]
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
                , Attr.min "0"
                , Attr.max "30"
                , value (toString intervalsPerBreak)
                , class [ BufferRight ]
                , style [ ( "font-size", "4.0rem" ) ]
                ]
                []
            , text theString
            ]


quitButton : Html Msg
quitButton =
    buttonNoTab [ onClick Quit, Attr.class "btn btn-primary btn-md btn-block" ] [ text "Quit" ]


invisibleTrigger : Html msg
invisibleTrigger =
    img [ src "./assets/invisible.png", Attr.class "invisible-trigger pull-left", style [ ( "max-width", "2.333em" ) ] ] []


configureView : Model -> Html Msg
configureView model =
    div [ Attr.class "container-fluid" ]
        [ div [ Attr.class "row" ]
            [ invisibleTrigger
            ]
        , buttonNoTab [ onClick StartTimer, Attr.class "btn btn-info btn-lg btn-block", class [ BufferTop ], title "Ctrl+Enter or ⌘+Enter", style [ ( "font-size", "2.85em" ), ( "padding", "0.3em" ) ] ] [ text "Start Mobbing" ]
        , div [ Attr.class "row" ]
            [ div [ Attr.class "col-md-4 col-sm-12" ] [ timerDurationInputView model.settings.timerDuration, breakIntervalInputView model.settings.intervalsPerBreak model.settings.timerDuration ]
            , div [ Attr.class "col-md-4 col-sm-6" ] [ mobstersView model.newMobster (Mobster.mobsters model.settings.mobsterData) model.dragDrop ]
            , div [ Attr.class "col-md-4 col-sm-6" ] [ inactiveMobstersView model.settings.mobsterData.inactiveMobsters model.dragDrop ]
            ]
        , div [ Attr.class "h1" ] [ experimentView model.newExperiment model.experiment ]
        , div [ Attr.class "row", class [ BufferTop ] ] [ quitButton ]
        ]


experimentView : String -> Maybe String -> Html Msg
experimentView newExperiment maybeExperiment =
    case maybeExperiment of
        Just experiment ->
            div [] [ text experiment, buttonNoTab [ onClick ChangeExperiment, Attr.class "btn btn-sm btn-primary" ] [ text "Edit experiment" ] ]

        Nothing ->
            div [ Attr.class "input-group" ]
                [ input [ id "add-mobster", placeholder "Try a daily experiment", type_ "text", Attr.class "form-control", value newExperiment, onInput UpdateExperimentInput, onEnter SetExperiment, style [ ( "font-size", "30px" ) ] ] []
                , span [ Attr.class "input-group-btn", type_ "button" ] [ buttonNoTab [ Attr.class "btn btn-primary", onClick SetExperiment ] [ text "Set" ] ]
                ]


continueButtonChildren : Model -> List (Html Msg)
continueButtonChildren model =
    case model.experiment of
        Just experimentText ->
            [ div [ Attr.class "col-md-4" ] [ text "Continue" ]
            , div
                [ Attr.class "col-md-8"
                , style
                    [ ( "font-size", "22px" )
                    , ( "font-style", "italic" )
                    , ( "text-align", "left" )
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
        div [ Attr.class "alert alert-warning alert-dismissible", style [ ( "font-size", "1.2em" ) ] ]
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


buttonNoTab : List (Attribute Msg) -> List (Html Msg) -> Html Msg
buttonNoTab attrs children =
    button ([ Attr.tabindex -1 ] ++ attrs) children


continueView : Bool -> Model -> Html Msg
continueView showRotation model =
    let
        mainView =
            if showRotation then
                rotationView model
            else
                div []
                    [ nextDriverNavigatorView model
                    , tipView model.tip
                    , div [ Attr.class "row", class [ BufferTop ], style [ ( "padding-bottom", "1.333em" ) ] ] [ buttonNoTab [ onClick OpenConfigure, Attr.class "btn btn-primary btn-md btn-block" ] [ text "Configure" ] ]
                    ]
    in
        div [ Attr.class "container-fluid" ]
            [ div [ Attr.class "row" ]
                [ invisibleTrigger
                ]
            , ratingsView model
            , div [] [ viewIntervalsBeforeBreak model ]
            , breakView model.secondsSinceBreak model.intervalsSinceBreak model.settings.intervalsPerBreak
            , div [ Attr.class "row", style [ ( "padding-bottom", "1.333em" ) ] ]
                [ buttonNoTab
                    [ onClick StartTimer
                    , Attr.class "btn btn-info btn-lg btn-block"
                    , class [ BufferTop ]
                    , title "Ctrl+Enter or ⌘+Enter"
                    , style [ ( "font-size", "2.0em" ), ( "padding", ".677em" ) ]
                    ]
                    (continueButtonChildren model)
                ]
            , mainView
            , div [ Attr.class "row", class [ BufferTop ] ] [ quitButton ]
            ]


tipView : Tip.Tip -> Html Msg
tipView tip =
    div [ Attr.class "jumbotron tip", style [ ( "margin", "0px" ), ( "padding", "1.667em" ) ] ]
        [ div [ Attr.class "row" ]
            [ h2 [ Attr.class "text-success pull-left", style [ ( "margin", "0px" ), ( "padding-bottom", "0.667em" ) ] ]
                [ text tip.title ]
            , a [ Attr.tabindex -1, target "_blank", Attr.class "btn btn-sm btn-primary pull-right", href tip.url ] [ text "Learn More" ]
            ]
        , div [ Attr.class "row" ] [ Tip.tipView tip ]
        ]


nextDriverNavigatorView : Model -> Html Msg
nextDriverNavigatorView model =
    let
        driverNavigator =
            Mobster.nextDriverNavigator model.settings.mobsterData
    in
        div [ Attr.class "row h1" ]
            [ div [ Attr.class "text-muted col-md-2 hidden-sm hidden-xs" ] [ text "Next:" ]
            , dnView driverNavigator.driver Mobster.Driver
            , dnView driverNavigator.navigator Mobster.Navigator
            , div [ Attr.class "col-md-1 col-sm-2" ]
                [ buttonNoTab [ class [ Orange ], Attr.class "btn btn-small btn-default", onClick (UpdateMobsterData Mobster.SkipTurn) ]
                    [ span [ Attr.class "glyphicon glyphicon-step-forward", class [ BufferRight ] ] []
                    , u [] [ text "S" ]
                    , text "kip Turn"
                    ]
                ]
            , div [ Attr.class "col-md-1 col-sm-2" ]
                [ buttonNoTab [ class [ Green ], Attr.class "btn btn-small btn-default", onClick ShowRotationScreen ]
                    [ span [ Attr.class "fa fa-user-plus", class [ BufferRight ] ]
                        []
                    , text "Quick "
                    , u [] [ text "R" ]
                    , text "otate"
                    ]
                ]
            ]


dnView : Mobster.Mobster -> Mobster.Role -> Html Msg
dnView mobster role =
    let
        icon =
            case role of
                Mobster.Driver ->
                    "./assets/driver-icon.png"

                Mobster.Navigator ->
                    "./assets/navigator-icon.png"
    in
        div [ Attr.class "col-md-4 col-sm-4 text-default" ]
            [ iconView icon 40
            , span [ class [ BufferRight ] ] [ text mobster.name ]
            , buttonNoTab [ class [ Red ], onClick (UpdateMobsterData (Mobster.Bench mobster.index)), Attr.class "btn btn-small btn-default" ]
                [ span [ Attr.class "fa fa-user-times", class [ BufferRight ] ] []
                , text "Not here"
                ]
            ]


iconView : String -> Int -> Html msg
iconView iconUrl maxWidth =
    img [ style [ ( "max-width", (toString maxWidth) ++ "px" ), ( "margin-right", "0.533em" ) ], src iconUrl ] []


nextView : String -> String -> Html msg
nextView thing name =
    span []
        [ span [ Attr.class "text-muted" ] [ text ("Next " ++ thing ++ ": ") ]
        , span [ Attr.class "text-info" ] [ text name ]
        ]


addMobsterInputView : String -> Html Msg
addMobsterInputView newMobster =
    div [ Attr.class "row", class [ BufferTop ] ]
        [ div [ Attr.class "input-group" ]
            [ input [ id "add-mobster", Attr.placeholder "Jane Doe", type_ "text", Attr.class "form-control", value newMobster, onInput UpdateMobsterInput, onEnter AddMobster, style [ ( "font-size", "2.0rem" ) ] ] []
            , span [ Attr.class "input-group-btn", type_ "button" ] [ buttonNoTab [ Attr.class "btn btn-primary", onClick ClickAddMobster ] [ text "Add Mobster" ] ]
            ]
        ]


mobstersView : String -> List Mobster.MobsterWithRole -> DragDropModel -> Html Msg
mobstersView newMobster mobsters dragDrop =
    div [ style [ ( "padding-bottom", "35px" ) ] ]
        [ addMobsterInputView newMobster
        , img [ onClick ShuffleMobsters, Attr.class "shuffle", class [ BufferTop ], src "./assets/dice.png", style [ ( "max-width", "1.667em" ) ] ] []
        , table [ Attr.class "table h3" ] (List.map (mobsterView dragDrop) mobsters)
        ]


letters : Array.Array String
letters =
    Array.fromList
        [ "a"
        , "b"
        , "c"
        , "d"
        , "e"
        , "f"
        , "g"
        , "h"
        , "i"
        , "j"
        , "k"
        , "l"
        , "m"
        , "n"
        , "o"
        , "p"
        ]


inactiveMobstersView : List String -> DragDropModel -> Html Msg
inactiveMobstersView inactiveMobsters dragDrop =
    let
        benchStyle =
            case ( DragDrop.getDragId dragDrop, DragDrop.getDropId dragDrop ) of
                ( Just _, Just DropBench ) ->
                    class [ DropAreaActive ]

                ( Just _, _ ) ->
                    class [ DropAreaInactive ]

                ( _, _ ) ->
                    class []
    in
        div (DragDrop.droppable DragDropMsg DropBench ++ [ benchStyle ])
            [ h2 [ Attr.class "text-center text-primary" ] [ text "Bench" ]
            , table [ Attr.class "table h3" ] (List.indexedMap inactiveMobsterView inactiveMobsters)
            ]


mobsterCellStyle : List (Attribute Msg)
mobsterCellStyle =
    [ style [ ( "text-align", "right" ), ( "padding-right", "0.667em" ) ] ]


hint : Int -> Html msg
hint index =
    let
        letter =
            Maybe.withDefault "?" (Array.get index letters)
    in
        span [ style [ ( "font-size", "0.7em" ) ] ] [ text (" (" ++ letter ++ ")") ]


inactiveMobsterViewWithHints : Int -> String -> Html Msg
inactiveMobsterViewWithHints mobsterIndex inactiveMobster =
    tr []
        [ td mobsterCellStyle
            [ span [ Attr.class "inactive-mobster", onClick (UpdateMobsterData (Mobster.RotateIn mobsterIndex)) ] [ text inactiveMobster ]
            , hint mobsterIndex
            ]
        ]


inactiveMobsterView : Int -> String -> Html Msg
inactiveMobsterView mobsterIndex inactiveMobster =
    tr []
        [ td mobsterCellStyle
            [ span [ Attr.class "inactive-mobster", onClick (UpdateMobsterData (Mobster.RotateIn mobsterIndex)) ] [ text inactiveMobster ]
            , div [ Attr.class "btn-group btn-group-xs", style [ ( "margin-left", "0.667em" ) ] ]
                [ buttonNoTab [ Attr.class "btn btn-small btn-danger", onClick (UpdateMobsterData (Mobster.Remove mobsterIndex)) ] [ text "x" ]
                ]
            ]
        ]


mobsterView : DragDropModel -> Mobster.MobsterWithRole -> Html Msg
mobsterView dragDrop mobster =
    let
        isBeingDraggedOver =
            case ( DragDrop.getDragId dragDrop, DragDrop.getDropId dragDrop ) of
                ( _, Just (DropActiveMobster id) ) ->
                    id == mobster.index

                _ ->
                    False

        hoverText =
            if isBeingDraggedOver then
                ">"
            else
                " "
    in
        tr
            (DragDrop.draggable DragDropMsg (ActiveMobster mobster.index) ++ DragDrop.droppable DragDropMsg (DropActiveMobster mobster.index))
            [ td [ Attr.class "active-hover" ] [ span [ style [ ( "color", "green" ) ] ] [ text hoverText ] ]
            , td mobsterCellStyle
                [ span [ Attr.classList [ ( "text-primary", mobster.role == Just Mobster.Driver ) ], Attr.class "active-mobster", onClick (UpdateMobsterData (Mobster.SetNextDriver mobster.index)) ]
                    [ text mobster.name
                    , roleView mobster.role
                    ]
                ]
            , td [] [ reorderButtonView mobster ]
            ]


roleView : Maybe Mobster.Role -> Html Msg
roleView role =
    case role of
        Just (Mobster.Driver) ->
            span [ Attr.class "role-icon driver-icon" ] []

        Just (Mobster.Navigator) ->
            span [ Attr.class "role-icon navigator-icon" ] []

        Nothing ->
            span [ Attr.class "role-icon no-role-icon" ] []


reorderButtonView : Mobster.MobsterWithRole -> Html Msg
reorderButtonView mobster =
    let
        mobsterIndex =
            mobster.index
    in
        div []
            [ div [ Attr.class "btn-group btn-group-xs" ]
                [ buttonNoTab [ Attr.class "btn btn-small btn-default", onClick (UpdateMobsterData (Mobster.Bench mobsterIndex)) ] [ text "x" ]
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
                , a [ onClick QuitAndInstall, Attr.href "#", Attr.class "alert-link" ] [ text "Update now" ]
                , text "."
                ]


rotationView : Model -> Html Msg
rotationView model =
    let
        mobsters =
            Mobster.mobsters model.settings.mobsterData

        inactiveMobsters =
            -- List.indexedMap (\index name -> Mobster.Mobster name index)
            model.settings.mobsterData.inactiveMobsters
    in
        div [ Attr.class "row" ]
            [ div [ Attr.class "col-md-6" ] [ table [ Attr.class "table h4" ] (List.map (mobsterView model.dragDrop) mobsters) ]
            , div [ Attr.class "col-md-6" ] [ table [ Attr.class "table h4" ] (List.indexedMap inactiveMobsterViewWithHints inactiveMobsters) ]
            ]


view : Model -> Html Msg
view model =
    let
        mainView =
            case model.screenState of
                Configure ->
                    configureView model

                Continue showRotation ->
                    continueView showRotation model

        -- Rotation ->
        -- rotationView model
    in
        div [] [ updateAvailableView model.availableUpdateVersion, mainView ]


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


rotateMobsters : Model -> Model
rotateMobsters ({ settings } as model) =
    { model | settings = { settings | mobsterData = (Mobster.rotate settings.mobsterData) } }


updateSettings : (Settings.Data -> Settings.Data) -> Model -> ( Model, Cmd Msg )
updateSettings settingsUpdater ({ settings } as model) =
    let
        updatedSettings =
            settingsUpdater settings
    in
        { model | settings = updatedSettings } ! [ saveSettings updatedSettings ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SkipHotkey ->
            case model.screenState of
                Continue showRotation ->
                    update (UpdateMobsterData Mobster.SkipTurn) model

                _ ->
                    model ! []

        ShowRotationScreen ->
            case model.screenState of
                Continue showRotation ->
                    { model | screenState = Continue (not showRotation) } ! []

                _ ->
                    model ! []

        StartTimer ->
            let
                updatedModel =
                    { model | screenState = Continue False }
                        |> rotateMobsters
                        |> resetIfAfterBreak
            in
                updatedModel ! [ (startTimer (flags model)), changeTip ]

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
            if model.newMobster == "" then
                model ! []
            else
                update (UpdateMobsterData (Mobster.Add model.newMobster)) { model | newMobster = "" }

        ClickAddMobster ->
            if model.newMobster == "" then
                model ! [ focusAddMobsterInput ]
            else
                { model | newMobster = "" }
                    ! [ focusAddMobsterInput ]
                    |> Update.Extra.andThen update (UpdateMobsterData (Mobster.Add model.newMobster))

        DomFocusResult _ ->
            model ! []

        UpdateMobsterData operation ->
            model
                |> updateSettings
                    (\settings -> { settings | mobsterData = Mobster.updateMoblist operation model.settings.mobsterData })

        UpdateMobsterInput text ->
            { model | newMobster = text } ! []

        Quit ->
            model ! [ quit () ]

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

        CopyActiveMobsters _ ->
            model ! [ (copyActiveMobsters (String.join ", " model.settings.mobsterData.mobsters)) ]

        ResetBreakData ->
            (model |> resetBreakData) ! []

        UpdateAvailable availableUpdateVersion ->
            { model | availableUpdateVersion = Just availableUpdateVersion } ! []

        QuitAndInstall ->
            model ! [ quitAndInstall () ]

        RotateInHotkey index ->
            if model.screenState == (Continue True) then
                update (UpdateMobsterData (Mobster.RotateIn index)) model
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
                                update (UpdateMobsterData (Mobster.Move id actualDropid)) updatedModel

                            ( ActiveMobster id, DropBench ) ->
                                update (UpdateMobsterData (Mobster.Bench id)) updatedModel

                            _ ->
                                model ! []


reorderOperation : List String -> Msg
reorderOperation shuffledMobsters =
    (UpdateMobsterData (Mobster.Reorder shuffledMobsters))


focusAddMobsterInput : Cmd Msg
focusAddMobsterInput =
    Task.attempt DomFocusResult (Dom.focus "add-mobster")


validateTimerDuration : String -> Int -> Int
validateTimerDuration newDurationAsString oldTimerDuration =
    let
        rawDuration =
            Result.withDefault 5 (String.toInt newDurationAsString)
    in
        if rawDuration > 15 then
            15
        else if rawDuration < 1 then
            1
        else
            rawDuration


validateBreakInterval : String -> Int -> Int
validateBreakInterval newDurationAsString oldTimerDuration =
    let
        rawDuration =
            Result.withDefault 6 (String.toInt newDurationAsString)
    in
        if rawDuration > 30 then
            30
        else if rawDuration < 0 then
            0
        else
            rawDuration


init : Decode.Value -> ( Model, Cmd Msg )
init flags =
    let
        decodedSettings =
            Settings.decode flags

        initialSettings =
            case decodedSettings of
                Ok settings ->
                    settings

                Err errorString ->
                    Settings.initial
    in
        initialModel initialSettings ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Keyboard.Combo.subscriptions model.combos
        , timeElapsed TimeElapsed
        , updateDownloaded UpdateAvailable
        , onCopyMobstersShortcut CopyActiveMobsters
        ]


main : Program Decode.Value Model Msg
main =
    Html.programWithFlags
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
