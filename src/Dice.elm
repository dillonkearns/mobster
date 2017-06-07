module Dice exposing (animateActiveMobstersShuffle, animateRoll)

import Animation exposing (Step)
import Time


animateRoll : { a | dieStyle : Animation.State } -> { a | dieStyle : Animation.State }
animateRoll model =
    { model | dieStyle = Animation.interrupt [ rollAnimation ] model.dieStyle }


animateActiveMobstersShuffle : { a | activeMobstersStyle : Animation.State } -> { a | activeMobstersStyle : Animation.State }
animateActiveMobstersShuffle model =
    { model
        | activeMobstersStyle =
            Animation.interrupt
                shuffleAnimation
                model.activeMobstersStyle
    }


shuffleAnimation : List Step
shuffleAnimation =
    [ Animation.toWith easing [ Animation.opacity 0 ]
    , Animation.toWith easing [ Animation.opacity 1 ]
    ]


rollAnimation : Step
rollAnimation =
    Animation.repeat 2
        [ Animation.set [ Animation.rotate (Animation.turn 0) ]
        , Animation.toWith easing [ Animation.rotate (Animation.turn 1) ]
        ]


easing : Animation.Interpolation
easing =
    Animation.easing { duration = Time.second / 2, ease = identity }
