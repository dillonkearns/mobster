module Dice exposing (animateActiveMobstersShuffle, animateRoll)

import Animation exposing (Step)
import Animation.Messenger
import Setup.Msg
import Time


animateRoll : { a | dieStyle : Animation.State } -> { a | dieStyle : Animation.State }
animateRoll model =
    { model | dieStyle = Animation.interrupt [ rollAnimation ] model.dieStyle }


animateActiveMobstersShuffle :
    { a | activeMobstersStyle : Animation.Messenger.State Setup.Msg.Msg }
    -> { a | activeMobstersStyle : Animation.Messenger.State Setup.Msg.Msg }
animateActiveMobstersShuffle model =
    { model
        | activeMobstersStyle =
            Animation.interrupt
                shuffleAnimation
                model.activeMobstersStyle
    }


shuffleAnimation : List (Animation.Messenger.Step Setup.Msg.Msg)
shuffleAnimation =
    [ Animation.toWith easing [ Animation.opacity 0 ]
    , Animation.Messenger.send Setup.Msg.RandomizeMobsters
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
    Animation.easing { duration = 1000 / 2, ease = identity }
