module QuickRotate exposing (..)


type Selection
    = All
    | New String
    | Index Int


type alias State =
    Selection


init : State
init =
    All


update : String -> List String -> State -> State
update query list state =
    let
        matches =
            list
                |> List.indexedMap (,)
                |> List.filter (\( index, item ) -> String.contains query item)

        firstMatchingIndex =
            case List.head matches of
                Nothing ->
                    Nothing

                Just ( index, _ ) ->
                    Just index
    in
        case firstMatchingIndex of
            Nothing ->
                New query

            Just firstMatchingIndex ->
                Index firstMatchingIndex
