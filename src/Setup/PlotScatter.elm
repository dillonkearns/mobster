module Setup.PlotScatter exposing (view)

import Plot exposing (..)
import Plot.Axis as Axis
import Plot.Line as Line
import Plot.Scatter as Scatter
import Svg


view : List ( Float, Float ) -> Svg.Svg a
view data =
    plot
        [ size plotSize
        , margin ( 10, 20, 40, 40 )
        , domainLowest (min 0)
        ]
        [ scatter
            [ Scatter.stroke pinkStroke
            , Scatter.fill pinkFill
            , Scatter.radius 4
            ]
            data
        , xAxis
            [ Axis.line
                [ Line.stroke axisColor ]
            , Axis.tickDelta 2
            ]
        ]


plotSize : ( Int, Int )
plotSize =
    ( 1600, 100 )


axisColor : String
axisColor =
    "#949494"


axisColorLight : String
axisColorLight =
    "#e4e4e4"


blueFill : String
blueFill =
    "#e4eeff"


blueStroke : String
blueStroke =
    "#cfd8ea"


skinFill : String
skinFill =
    "#feefe5"


skinStroke : String
skinStroke =
    "#f7e0d2"


pinkFill : String
pinkFill =
    "#fdb9e7"


pinkStroke : String
pinkStroke =
    "#ff9edf"
