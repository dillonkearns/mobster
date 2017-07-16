module ContinueView exposing (view)

-- import Style.Attributes as Attr

import Element exposing (Device)
import Element.Attributes as Attr
import Styles exposing (StyleElement)


view : Device -> List StyleElement
view device =
    [ breakProgressView
    , roleRow device
    , Element.hairline Styles.Hairline
    , tipView
    , Styles.startMobbingButton "Continue"
    ]


tipView : StyleElement
tipView =
    Element.column Styles.TipBox
        [ Attr.width (Attr.percent 50)
        , Attr.center
        , Attr.padding 20
        ]
        [ Element.el Styles.TipTitle [ Attr.paddingBottom 15 ] <| Element.text "Driver Navigator Pattern"
        , Element.column Styles.TipBody
            [ Attr.center, Attr.width (Attr.percent 55) ]
            [ Element.el Styles.None [] <| Element.text "For an idea to go from your head into the computer it MUST go through someone else's hands."
            , Element.text "Llewellyn Falco" |> Element.el Styles.TipLink [ Attr.target "_blank" ] |> Element.link "https://twitter.com/LlewellynFalco/"
            ]
        ]


type Role
    = Driver
    | Navigator


roleView : Device -> Role -> String -> StyleElement
roleView device role name =
    Element.row Styles.None
        [ Attr.spacing 20, Attr.verticalCenter, Attr.center ]
        [ roleIcon device role, Element.el Styles.RoleViewName [] <| Element.text name ]
        |> Element.onRight [ Element.el Styles.None [ Attr.verticalCenter, Attr.paddingLeft 30 ] awayView ]


roleRow : Device -> StyleElement
roleRow device =
    Element.row Styles.None
        []
        [ stepBackwardButton
        , Element.el Styles.None [ Attr.width (Attr.fill 1) ] (roleView device Driver "Sulu")
        , Element.el Styles.None [ Attr.width (Attr.fill 1) ] (roleView device Navigator "Kirk")
        , stepForwardButton
        ]


stepForwardButton : StyleElement
stepForwardButton =
    Element.el Styles.StepButton [ Attr.paddingXY 16 10, Attr.class "fa fa-step-forward", Attr.verticalCenter ] Element.empty


stepBackwardButton : StyleElement
stepBackwardButton =
    Element.el Styles.StepButton [ Attr.paddingXY 16 10, Attr.class "fa fa-step-backward", Attr.verticalCenter ] Element.empty


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
