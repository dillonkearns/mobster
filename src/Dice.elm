module Dice exposing (animateRoll)

import Animation exposing (Step)
import Time


animateRoll : { a | dieStyle : Animation.State } -> { a | dieStyle : Animation.State }
animateRoll model =
    { model | dieStyle = Animation.interrupt rollAnimation model.dieStyle }


rollAnimation : List Step
rollAnimation =
    [ Animation.set [ Animation.rotate (Animation.turn 0) ]
    , Animation.toWith easing [ Animation.rotate (Animation.turn 1) ]
    ]


easing : Animation.Interpolation
easing =
    Animation.easing { duration = Time.second / 2, ease = identity }
