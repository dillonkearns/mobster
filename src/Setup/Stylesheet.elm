module Setup.Stylesheet exposing (..)

import Css exposing (..)
import Css.Elements exposing (body, html, span)
import Css.Namespace exposing (namespace)


type CssClasses
    = BufferTop
    | BufferRight
    | Green
    | Orange
    | Red
    | DropAreaInactive
    | DropAreaActive
    | LargeButtonText
    | TooltipContainer
    | Tooltip
    | ShowOnParentHover
    | ShowOnParentHoverParent


css : Stylesheet
css =
    (stylesheet << namespace "setup")
        [ mediaQuery "screen and ( max-width: 800px )"
            [ body
                [ fontSize (px 7) ]
            ]
        , mediaQuery "screen and ( min-width: 801px ) and ( max-width: 1000px )"
            [ body
                [ fontSize (px 10) ]
            ]
        , mediaQuery "screen and ( min-width: 1001px )"
            [ body
                [ fontSize (px 15) ]
            ]
        , class BufferTop
            [ Css.marginTop (px 20) ]
        , class BufferRight
            [ marginRight (px 10)
            ]
        , class Green (hoverButton (rgba 50 250 50 0.6))
        , class Red (hoverButton (rgba 231 76 60 0.7))
        , class Orange (hoverButton (rgba 255 133 27 1))
        , class DropAreaInactive [ borderStyle Css.dotted ]
        , class DropAreaActive [ backgroundColor (rgba 250 150 100 0.5), borderStyle Css.dotted ]
        , class LargeButtonText [ fontSize (em 2.85), padding (em 0.3) ]
        , tooltipStyle
        , class ShowOnParentHoverParent
            [ children [ class ShowOnParentHover [ opacity (int 0) ] ]
            , hover
                [ children
                    [ class ShowOnParentHover
                        [ opacity (num 0.4)
                        , hover [ opacity (num 0.9) ]
                        ]
                    ]
                ]
            ]
        ]


hoverButton : ColorValue compatible -> List Mixin
hoverButton customColor =
    [ hover
        [ children
            [ span [ color customColor ]
            , selector "u" [ color customColor ]
            ]
        ]
    ]


tooltipStyle : Snippet
tooltipStyle =
    class TooltipContainer
        -- /* Tooltip CSS  - help from https://jsfiddle.net/greypants/zgCb7/ */
        [ Css.transform (translateZ (zero))
        , children
            [ class Tooltip
                [ left (Css.pct 50) |> important
                , right (auto) |> important
                , textAlign (center) |> important
                , transform (translate2 (pct -50) (zero)) |> important
                , fontSize (Css.rem 2.5)
                , Css.backgroundColor (rgba 14 255 125 1)
                , bottom (pct 100)
                , color (hex "#fff")
                , display block
                , left zero
                , marginBottom (px 15)
                , opacity zero
                , padding (px 20)
                , position absolute
                , transform (translateY (px 10))
                , Css.property "transition" "all .15s ease-out"
                , boxShadow4 (px 2) (px 2) (px 6) (rgba 0 0 0 0.28)
                , property "pointer-events" "none"
                , after
                    [ Css.property "border-left" "solid transparent 10px"
                    , Css.property "border-right" "solid transparent 10px"
                    , Css.property "border-top" "solid rgba(14, 255, 125, 1) 10px"
                    , bottom (px -10)
                    , Css.property "content" "' '"
                    , height zero
                    , left (pct 50)
                    , marginLeft (px -13)
                    , position absolute
                    , width zero
                    ]
                , before
                    -- /* This bridges the gap so you can mouse into the tooltip without it disappearing */
                    [ bottom (px -20)
                    , property "content" "' '"
                    , display block
                    , height (px 20)
                    , left zero
                    , position absolute
                    , width (pct 100)
                    ]
                ]
            ]
        , hover
            [ children
                [ class Tooltip
                    [ opacity (Css.int 1)
                    , transform (translateY zero)
                    , property "pointer-events" "auto"
                    ]
                ]
            ]
        ]
