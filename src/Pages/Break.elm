module Pages.Break exposing (view)

import Element exposing (Device, button, el, empty, row, text)
import Element.Attributes exposing (center, fill, padding, paddingXY, spacing, verticalCenter, width)
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
        [ width (fill 1), paddingXY 16 16, spacing 10, center, verticalCenter ]
        [ el Styles.None [ Element.Attributes.class "fa fa-exclamation-circle" ] empty
        , text <| "How about a walk? You've been mobbing for " ++ toString (secondsSinceBreak // 60) ++ " minutes."
        ]


breakButtons : StyleElement
breakButtons =
    row Styles.None
        [ spacing 30 ]
        [ button <|
            el Styles.SkipBreakButton
                [ padding 13, width (fill 1), Element.Events.onClick Msg.SkipBreak ]
                (row Styles.None
                    [ spacing 20, center ]
                    [ text "Skip Break" ]
                )

        -- |> above [ el Tooltip [ center, width (px 200), class "setupTooltip" ] (text "This is a tooltip") ]
        , button <|
            el Styles.BreakButton
                [ padding 13, width (fill 3), Element.Events.onClick Msg.StartBreak ]
                (row Styles.None
                    [ spacing 20, center ]
                    [ text "Take a Break"
                    , el Styles.None [ Element.Attributes.class "fa fa-coffee", verticalCenter ] empty
                    ]
                )
        ]
