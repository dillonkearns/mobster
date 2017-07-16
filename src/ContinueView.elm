module ContinueView exposing (view)

-- import Style.Attributes as Attr

import Element exposing (Device)
import Element.Attributes as Attr
import Element.Events
import Roster.Data exposing (RosterData)
import Roster.Operation as MobsterOperation
import Roster.Presenter
import Setup.Msg as Msg exposing (Msg)
import Setup.Settings as Settings
import Styles exposing (StyleElement)
import Tip exposing (Tip)


view : { model | device : Device, tip : Tip, settings : Settings.Data } -> List StyleElement
view { device, tip, settings } =
    [ breakProgressView
    , roleRow device settings.rosterData
    , Element.hairline Styles.Hairline
    , tipView tip
    , Styles.startMobbingButton "Continue"
    ]


tipView : Tip -> StyleElement
tipView tip =
    Element.column Styles.TipBox
        [ Attr.width (Attr.percent 50)
        , Attr.center
        , Attr.padding 20
        ]
        [ Element.el Styles.TipTitle [ Attr.paddingBottom 15 ] <| Element.text tip.title
        , Element.column Styles.TipBody
            [ Attr.center, Attr.width (Attr.percent 55) ]
            [ Element.el Styles.None [] <| Element.text tip.body
            , Element.text tip.author |> Element.el Styles.TipLink [ Attr.target "_blank" ] |> Element.link tip.url
            ]
        ]


type Role
    = Driver
    | Navigator


roleView : Device -> Role -> Roster.Presenter.Mobster -> StyleElement
roleView device role mobster =
    Element.row Styles.None
        [ Attr.spacing 20, Attr.verticalCenter, Attr.center ]
        [ roleIcon device role, Element.el Styles.RoleViewName [] <| Element.text mobster.name ]
        |> Element.onRight [ Element.el Styles.None [ Attr.verticalCenter, Attr.paddingLeft 30 ] awayView ]


roleRow : Device -> RosterData -> StyleElement
roleRow device rosterData =
    let
        driverNavigator : Roster.Presenter.DriverNavigator
        driverNavigator =
            Roster.Presenter.nextDriverNavigator rosterData
    in
    Element.row Styles.None
        []
        [ stepBackwardButton
        , Element.el Styles.None [ Attr.width (Attr.fill 1) ] (roleView device Driver driverNavigator.driver)
        , Element.el Styles.None [ Attr.width (Attr.fill 1) ] (roleView device Navigator driverNavigator.navigator)
        , stepForwardButton
        ]


stepButton : String -> Msg -> StyleElement
stepButton iconClass msg =
    Element.el Styles.StepButton
        [ Attr.paddingXY 16 10
        , Attr.class ("fa " ++ iconClass)
        , Attr.verticalCenter
        , Element.Events.onClick msg
        ]
        Element.empty


stepForwardButton : StyleElement
stepForwardButton =
    stepButton "fa-step-forward" (Msg.UpdateRosterData MobsterOperation.NextTurn)


stepBackwardButton : StyleElement
stepBackwardButton =
    stepButton "fa-step-backward" (Msg.UpdateRosterData MobsterOperation.RewindTurn)


awayView : StyleElement
awayView =
    Element.el Styles.AwayIcon [ Attr.paddingXY 16 10 ] <|
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


breakProgressView : StyleElement
breakProgressView =
    Element.row Styles.None
        [ Attr.spacing 1 ]
        [ circleView Styles.Filled
        , circleView Styles.Hollow
        ]


circleView : Styles.CircleFill -> StyleElement
circleView circleFill =
    Element.el (Styles.Circle circleFill) [ Attr.width (Attr.px 15), Attr.height (Attr.px 15) ] Element.empty
