module Timer.Timer
    exposing
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
    Timer (seconds // 60) (rem seconds 60)


timerToString : Timer -> String
timerToString { minutes, seconds } =
    toString minutes ++ ":" ++ String.pad 2 '0' (toString seconds)
