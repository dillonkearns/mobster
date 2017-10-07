module Page.Break exposing (view)

import Element exposing (Device, button, el, empty, row, text)
import Element.Attributes exposing (center, fill, fillPortion, padding, paddingXY, percent, spacing, verticalCenter, width)
import Element.Events
import Setup.Msg as Msg
import Styles exposing (StyleElement)


view : { model | secondsSinceBreak : Int } -> List StyleElement
view { secondsSinceBreak } =
    [ breakSuggestionView secondsSinceBreak
    , breakButtons
    ]


breakSuggestionView : Int -> StyleElement
breakSuggestionView secondsSinceBreak =
    row Styles.BreakAlertBox
        [ width fill, paddingXY 16 16, spacing 10, center, verticalCenter ]
        [ el Styles.None [ Element.Attributes.class "fa fa-exclamation-circle" ] empty
        , text <| "How about a walk? You've been mobbing for " ++ toString (secondsSinceBreak // 60) ++ " minutes."
        ]


breakButtons : StyleElement
breakButtons =
    row Styles.None
        [ spacing 30 ]
        [ button
            Styles.SkipBreakButton
            [ padding 13, width (fillPortion 1), Element.Events.onClick Msg.SkipBreak ]
            (row Styles.None
                [ spacing 20, center, width (Element.Attributes.percent 100) ]
                [ text "Skip Break" ]
            )
        , button
            Styles.BreakButton
            [ padding 13, width (fillPortion 3), Element.Events.onClick Msg.StartBreak ]
            (row Styles.None
                [ spacing 20, center, width (Element.Attributes.percent 100) ]
                [ text "Take a Break"
                , el Styles.None [ Element.Attributes.class "fa fa-coffee" ] empty
                ]
            )
        ]
