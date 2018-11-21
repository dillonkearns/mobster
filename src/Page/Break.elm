module Page.Break exposing (view)

import Element exposing (button, el, empty, row, text)
import Element.Attributes as Attr
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
        [ Attr.width Attr.fill, Attr.paddingXY 16 16, Attr.spacing 10, Attr.center, Attr.verticalCenter ]
        [ el Styles.None [ Attr.class "fa fa-exclamation-circle" ] empty
        , text <| "How about a walk? You've been mobbing for " ++ String.fromInt (secondsSinceBreak // 60) ++ " minutes."
        ]


breakButtons : StyleElement
breakButtons =
    row Styles.None
        [ Attr.spacing 30 ]
        [ button
            Styles.SkipBreakButton
            [ Attr.padding 13, Attr.width (Attr.fillPortion 1), Element.Events.onClick Msg.SkipBreak ]
            (row Styles.None
                [ Attr.spacing 20, Attr.center, Attr.width (Attr.percent 100) ]
                [ text "Skip Break" ]
            )
        , button
            Styles.BreakButton
            [ Attr.padding 13, Attr.width (Attr.fillPortion 3), Element.Events.onClick Msg.StartTimer ]
            (row Styles.None
                [ Attr.spacing 20, Attr.center, Attr.width (Attr.percent 100) ]
                [ text "Take a Break"
                , el Styles.None [ Attr.class "fa fa-coffee" ] empty
                ]
            )
        ]
