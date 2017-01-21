module Timer exposing (..)

import Html exposing (..)


timer : Timer
timer =
    Timer 5 0


main : Html msg
main =
    div [] [ text (timerToString timer) ]


type alias Timer =
    { minutes : Int, seconds : Int }


secondsToTimer : Int -> Timer
secondsToTimer seconds =
    Timer (seconds // 60) (rem seconds 60)


timerToString : Timer -> String
timerToString { minutes, seconds } =
    (toString minutes) ++ ":" ++ (String.pad 2 '0' (toString seconds))
