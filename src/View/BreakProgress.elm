module View.BreakProgress exposing (view)

import Element exposing (Device)
import Element.Attributes as Attr
import Element.Events
import Setup.Msg as Msg
import Setup.Settings as Settings
import Styles exposing (StyleElement)


circleView : { model | device : Device } -> Styles.CircleFill -> StyleElement
circleView { device } circleFill =
    let
        width =
            Styles.responsiveForWidth device ( 6, 25 ) |> Attr.px

        height =
            Styles.responsiveForWidth device ( 10, 32 ) |> Attr.px
    in
    Element.el (Styles.Circle circleFill) [ Attr.width width, Attr.height height ] Element.empty


view : { model | intervalsSinceBreak : Int, settings : Settings.Data, device : Device } -> Styles.StyleElement
view ({ intervalsSinceBreak, settings } as model) =
    let
        intervalBadges =
            List.range 1 settings.intervalsPerBreak
                |> List.map (\index -> index > intervalsSinceBreak)
                |> List.map
                    (\incompleteInterval ->
                        if incompleteInterval then
                            circleView model Styles.Hollow
                        else
                            circleView model Styles.Filled
                    )
    in
    Element.row
        Styles.None
        [ Attr.spacing 0
        , Element.Events.onClick Msg.ResetBreakData
        ]
        intervalBadges
