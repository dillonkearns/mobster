module Break exposing (breakSuggested, breaksTurnedOn)


breakSuggested : Int -> Int -> Bool
breakSuggested timersSinceBreak timersPerBreak =
    breaksTurnedOn timersPerBreak && timersSinceBreak >= timersPerBreak


breaksTurnedOn : Int -> Bool
breaksTurnedOn timersPerBreak =
    timersPerBreak > 0
