module Array.Extra exposing (removeAt)

import Array exposing (Array)


removeAt : Int -> Array a -> Array a
removeAt index xs =
    -- TODO: refactor (written this way to help avoid Array bugs)
    let
        ( xs0, xs1 ) =
            splitAt index xs

        len1 =
            Array.length xs1
    in
    if len1 == 0 then
        xs0

    else
        Array.append xs0 (Array.slice 1 len1 xs1)


splitAt : Int -> Array a -> ( Array a, Array a )
splitAt index xs =
    -- TODO: refactor (written this way to help avoid Array bugs)
    let
        len =
            Array.length xs
    in
    case ( index > 0, index < len ) of
        ( True, True ) ->
            ( Array.slice 0 index xs, Array.slice index len xs )

        ( True, False ) ->
            ( xs, Array.empty )

        ( False, True ) ->
            ( Array.empty, xs )

        ( False, False ) ->
            ( Array.empty, Array.empty )
