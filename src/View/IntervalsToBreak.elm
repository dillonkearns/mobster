module View.IntervalsToBreak exposing (view)

import Break
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Setup.Msg as Msg exposing (Msg)


view : Int -> Int -> Html Msg
view intervalsSinceBreak intervalsPerBreak =
    let
        remainingIntervals =
            Break.timersBeforeNext intervalsSinceBreak intervalsPerBreak

        intervalBadges =
            List.range 1 intervalsPerBreak
                |> List.map (\index -> index > intervalsSinceBreak)
                |> List.map
                    (\grayBadge ->
                        if grayBadge then
                            span [ Attr.class "label label-default" ] [ text " " ]
                        else
                            span [ Attr.class "label label-info" ] [ text " " ]
                    )
    in
    div [ onClick Msg.ResetBreakData ] intervalBadges
