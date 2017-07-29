module Views.BreakProgress exposing (view)

import Break
import Element exposing (Device)
import Element.Attributes as Attr
import Element.Events
import Setup.Msg as Msg
import Setup.Settings as Settings
import Styles exposing (StyleElement)


circleView : Styles.CircleFill -> StyleElement
circleView circleFill =
    Element.el (Styles.Circle circleFill) [ Attr.width (Attr.px 12), Attr.height (Attr.px 18) ] Element.empty


view : { model | intervalsSinceBreak : Int, settings : Settings.Data } -> Styles.StyleElement
view { intervalsSinceBreak, settings } =
    let
        remainingIntervals =
            Break.timersBeforeNext intervalsSinceBreak settings.intervalsPerBreak

        intervalBadges =
            List.range 1 settings.intervalsPerBreak
                |> List.map (\index -> index > intervalsSinceBreak)
                |> List.map
                    (\incompleteInterval ->
                        if incompleteInterval then
                            circleView Styles.Hollow
                        else
                            circleView Styles.Filled
                    )
    in
    Element.row
        Styles.None
        [ Attr.spacing 0
        , Element.Events.onClick Msg.ResetBreakData
        ]
        intervalBadges
