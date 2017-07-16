module Views.StepButton exposing (stepBackwardButton, stepForwardButton)

import Element exposing (Device)
import Element.Attributes as Attr
import Element.Events
import Roster.Operation as MobsterOperation
import Setup.Msg as Msg exposing (Msg)
import Styles exposing (StyleElement)


stepForwardButton : StyleElement
stepForwardButton =
    stepButton "fa-step-forward" (Msg.UpdateRosterData MobsterOperation.NextTurn)


stepBackwardButton : StyleElement
stepBackwardButton =
    stepButton "fa-step-backward" (Msg.UpdateRosterData MobsterOperation.RewindTurn)


stepButton : String -> Msg -> StyleElement
stepButton iconClass msg =
    Element.el Styles.StepButton
        [ Attr.paddingXY 16 10
        , Attr.class ("fa " ++ iconClass)
        , Attr.verticalCenter
        , Element.Events.onClick msg
        ]
        Element.empty
