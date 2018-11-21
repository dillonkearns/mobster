module Page.BreakBeta exposing (view)

import Element
import Element.Attributes as Attr
import Element.Events
import Setup.Msg as Msg
import Styles exposing (StyleElement)
import Timer.Timer
import Tip exposing (Tip)


view :
    { model | secondsSinceBreak : Int, tip : Tip }
    -> Int
    -> List StyleElement
view model breakSecondsLeft =
    [ timerView breakSecondsLeft
    , Element.hairline Styles.Hairline
    , breakTipView

    -- , breakSuggestionView model
    -- , breakButtons breakSecondsLeft
    ]


timerView : Int -> StyleElement
timerView breakSecondsLeft =
    breakSecondsLeft
        |> Timer.Timer.secondsToTimer
        |> Timer.Timer.timerToString
        |> Element.text
        |> Element.el Styles.BreakTimer []


fa : Styles.Styles -> String -> StyleElement
fa style faClass =
    Element.el style [ Attr.class <| "fa " ++ faClass ] Element.empty


breakTipView : StyleElement
breakTipView =
    -- row Styles.BreakAlertBox
    --     [ Attr.width Attr.fill, Attr.paddingXY 16 16, Attr.spacing 10, Attr.center, Attr.verticalCenter ]
    --     [ fa Styles.None "fa-exclamation-circle"
    --     , text <| "Name one repeated task you encountered today. What would it look like if it were automated?"
    --     ]
    let
        retroTip =
            { title = "Mini-Retro"
            , body = "Name one repeated task you encountered today. What would it look like if it were automated?"
            , style = Styles.RetroTipBox
            }

        breakTip =
            { title = "1-Minute Break", body = "How about a stretch?", style = Styles.BreakTipBox }

        tip =
            -- breakTip
            retroTip
    in
    -- Element.column Styles.TipBox
    -- Element.column Styles.BreakAlertBox
    Element.column tip.style
        [ Attr.center
        , Attr.width Attr.fill
        , Attr.padding 20
        ]
        [ Element.text tip.title
            |> Element.el Styles.BreakTipTitle
                [ Attr.paddingBottom 15
                , Attr.attribute "target" "_blank"

                -- , Element.Events.onClick (Msg.SendIpc (Ipc.OpenExternalUrl tip.url))
                ]
        , Element.column Styles.TipBody
            [ Attr.center
            , Attr.width (Attr.percent 55)
            , Attr.spacing 15
            ]
            [ [ Element.text tip.body ] |> Element.paragraph Styles.None []

            -- , Element.text tip.author
            ]
        ]


breakSuggestionView :
    { model | secondsSinceBreak : Int }
    -> StyleElement
breakSuggestionView { secondsSinceBreak } =
    Element.row Styles.BreakAlertBox
        [ Attr.width Attr.fill, Attr.paddingXY 16 16, Attr.spacing 10, Attr.center, Attr.verticalCenter ]
        [ fa Styles.None "fa-exclamation-circle"
        , Element.text <| "How about a walk? You've been mobbing for " ++ String.fromInt (secondsSinceBreak // 60) ++ " minutes."
        ]


breakButtons : Int -> StyleElement
breakButtons breakSecondsLeft =
    Element.row Styles.None
        [ Attr.spacing 30 ]
        [ Element.button
            Styles.SkipBreakButton
            [ Attr.padding 13, Attr.width (Attr.fillPortion 1), Element.Events.onClick Msg.SkipBreak ]
            (Element.row Styles.None
                [ Attr.spacing 20, Attr.center, Attr.width (Attr.percent 100) ]
                [ Element.text "Skip Break" ]
            )
        , Element.button
            Styles.BreakButton
            [ Attr.padding 13, Attr.width (Attr.fillPortion 3), Element.Events.onClick Msg.StartTimer ]
            (Element.row Styles.None
                [ Attr.spacing 20, Attr.center, Attr.width (Attr.percent 100) ]
                [ Element.text "Hide Until Break Done"
                , fa Styles.None "fa-coffee"
                ]
            )
        ]
