module Page.Continue exposing (view)

import Element exposing (Device)
import Element.Attributes as Attr
import Element.Events
import Os exposing (Os)
import Roster.Data exposing (RosterData)
import Roster.Operation as MobsterOperation
import Roster.Presenter
import Setup.Msg as Msg
import Setup.Settings as Settings
import Styles exposing (StyleElement)
import Tip exposing (Tip)
import View.StartMobbingButton
import Views.BreakProgress
import Views.StepButton
import Views.Tip


view :
    { model
        | device : Device
        , tip : Tip
        , settings : Settings.Data
        , intervalsSinceBreak : Int
        , os : Os
    }
    -> List StyleElement
view ({ device, tip, settings } as model) =
    [ Element.column Styles.None
        []
        [ Views.BreakProgress.view model
        , Element.el Styles.None [ Attr.paddingTop 10, Attr.paddingBottom 20 ] <| roleRow device settings.rosterData
        , Element.hairline Styles.Hairline
        ]
    , Views.Tip.view tip
    , View.StartMobbingButton.view model "Continue"
    ]


type Role
    = Driver
    | Navigator


roleView : Device -> Role -> Roster.Presenter.Mobster -> StyleElement
roleView device role mobster =
    Element.row Styles.None
        [ Attr.spacing 20, Attr.verticalCenter, Attr.center, Attr.width Attr.fill ]
        [ roleIcon device role
        , Element.text mobster.name
            |> Element.el Styles.H1 []
            |> Element.onRight [ Element.el Styles.None [ Attr.verticalCenter, Attr.paddingLeft 30 ] (awayView mobster.index) ]
        ]


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
        , Element.el Styles.None [ Attr.width Attr.fill ] (roleView device Driver driverNavigator.driver)
        , Element.el Styles.None [ Attr.width Attr.fill ] (roleView device Navigator driverNavigator.navigator)
        , Views.StepButton.stepForwardButton
        ]


awayView : Int -> StyleElement
awayView index =
    Element.row Styles.AwayIcon
        [ Attr.paddingXY 16 10
        , Attr.spacing 10
        , Element.Events.onClick <| Msg.UpdateRosterData (MobsterOperation.Bench index)
        ]
        [ Element.el Styles.AwayX [] <| Element.text "✖", Element.text "Away" ]


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
    Element.image Styles.None [ Attr.height iconHeight ] { src = iconPath, caption = "role" }
