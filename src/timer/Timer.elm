module Timer.Timer exposing (..)


type alias Timer =
    { minutes : Int, seconds : Int }


secondsToTimer : Int -> Timer
secondsToTimer seconds =
    Timer (seconds // 60) (rem seconds 60)


timerToString : Timer -> String
timerToString { minutes, seconds } =
    (toString minutes) ++ ":" ++ (String.pad 2 '0' (toString seconds))
