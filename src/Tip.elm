module Tip exposing (Tip, emptyTip, get, random)

import Array
import Random


type alias Tip =
    { url : String
    , body : String
    , title : String
    , author : String
    }


get : List Tip -> Int -> Tip
get tips index =
    let
        maybeTip =
            Array.get index (Array.fromList tips)
    in
    Maybe.withDefault emptyTip maybeTip


random : List Tip -> Random.Generator Int
random tips =
    Random.int 0 (List.length tips - 1)


emptyTip : Tip
emptyTip =
    { url = "", title = "", body = "", author = "" }
