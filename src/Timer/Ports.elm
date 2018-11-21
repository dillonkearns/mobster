port module Timer.Ports exposing (breakTimerDone, timerDone)


port timerDone : Int -> Cmd msg


port breakTimerDone : Int -> Cmd msg
