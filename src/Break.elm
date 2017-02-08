module Break exposing (..)


timersBeforeNext : Int -> Int -> Int -> ( Int, Int )
timersBeforeNext minutesSinceBreak timerMinutes breakIntervalMinutes =
    let
        timersRemaining =
            if minutesSinceBreak >= breakIntervalMinutes then
                0
            else
                (toFloat (breakIntervalMinutes - minutesSinceBreak)) / (toFloat timerMinutes) |> Basics.ceiling

        totalBreaksPerInterval =
            breakIntervalMinutes // timerMinutes
    in
        ( timersRemaining, totalBreaksPerInterval )
