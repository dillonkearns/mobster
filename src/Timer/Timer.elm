module Timer.Timer exposing
    ( Timer
    , secondsToTimer
    , timerComplete
    , timerToString
    , updateTimer
    )


type alias Timer =
    { minutes : Int
    , seconds : Int
    }


updateTimer : Int -> Int
updateTimer seconds =
    seconds - 1


timerComplete : Int -> Bool
timerComplete secondsLeft =
    secondsLeft <= 0


secondsToTimer : Int -> Timer
secondsToTimer seconds =
    Timer (seconds // 60) (remainderBy 60 seconds)


timerToString : Timer -> String
timerToString { minutes, seconds } =
    String.fromInt minutes ++ ":" ++ String.pad 2 '0' (String.fromInt seconds)
