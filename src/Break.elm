module Break exposing (..)


timersBeforeNext : Int -> Int -> Int
timersBeforeNext timersSinceBreak timersPerBreak =
    if timersSinceBreak >= timersPerBreak then
        0
    else
        timersPerBreak - timersSinceBreak


breakSuggested : Int -> Int -> Bool
breakSuggested timersSinceBreak timersPerBreak =
    timersSinceBreak >= timersPerBreak
