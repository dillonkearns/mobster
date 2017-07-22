module Page.Continue exposing (view)

import Element exposing (Device)
import Element.Attributes as Attr exposing (spacing)
import Element.Events
import Roster.Data exposing (RosterData)
import Roster.Operation as MobsterOperation
import Roster.Presenter
import Setup.Msg as Msg
import Setup.Settings as Settings
import Styles exposing (StyleElement)
import Tip exposing (Tip)
import Views.BreakProgress
import Views.StepButton
import Views.Tip


view :
    { model
        | device : Device
        , tip : Tip
        , settings : Settings.Data
        , intervalsSinceBreak : Int
        , onMac : Bool
    }
    -> List StyleElement
view ({ device, tip, settings, onMac } as model) =
    [ Element.column Styles.None
        []
        [ Views.BreakProgress.view model
        , Element.el Styles.None [ Attr.paddingTop 10, Attr.paddingBottom 20 ] <| roleRow device settings.rosterData
        , Element.hairline Styles.Hairline
        ]
    , Views.Tip.view tip
    , Styles.startMobbingButton onMac "Continue"
    ]


type Role
    = Driver
    | Navigator


roleView : Device -> Role -> Roster.Presenter.Mobster -> StyleElement
roleView device role mobster =
    Element.row Styles.None
        [ Attr.spacing 20, Attr.verticalCenter, Attr.center ]
        [ roleIcon device role, Element.el Styles.RoleViewName [] <| Element.text mobster.name ]
        |> Element.onRight [ Element.el Styles.None [ Attr.verticalCenter, Attr.paddingLeft 30 ] (awayView mobster.index) ]


roleRow : Device -> RosterData -> StyleElement
roleRow device rosterData =
    let
        driverNavigator : Roster.Presenter.DriverNavigator
        driverNavigator =
            Roster.Presenter.nextDriverNavigator rosterData
    in
    Element.row Styles.None
        []
        [ Views.StepButton.stepBackwardButton
        , Element.el Styles.None [ Attr.width (Attr.fill 1) ] (roleView device Driver driverNavigator.driver)
        , Element.el Styles.None [ Attr.width (Attr.fill 1) ] (roleView device Navigator driverNavigator.navigator)
        , Views.StepButton.stepForwardButton
        ]


awayView : Int -> StyleElement
awayView index =
    Element.el Styles.AwayIcon
        [ Attr.paddingXY 16 10
        , Element.Events.onClick <| Msg.UpdateRosterData (MobsterOperation.Bench index)
        ]
    <|
        Element.text "✖ Away"


roleIcon : Device -> Role -> StyleElement
roleIcon device role =
    let
        iconPath =
            case role of
                Driver ->
                    "./assets/driver-icon.png"

                Navigator ->
                    "./assets/navigator-icon.png"

        iconHeight =
            Styles.responsiveForWidth device ( 30, 150 ) |> Attr.px
    in
    Element.image iconPath Styles.None [ Attr.height iconHeight ] Element.empty
