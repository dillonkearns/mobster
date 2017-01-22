port module Setup.Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)


main : Html msg
main =
    h1 [ class "text-primary text-center" ]
        [ text "Mobster"
        , div [ class "text-center" ]
            [ button [ class "btn btn-primary btn-lg" ] [ text "Start mobbing" ]
            ]
        ]
