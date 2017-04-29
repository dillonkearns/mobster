module QuickRotate exposing (..)


type Selection
    = All
    | New String
    | Index Int


type alias State =
    { selection : Selection
    , query : String
    }


init : State
init =
    { selection = All
    , query = ""
    }


next : List String -> State -> State
next list state =
    { state | selection = Index 1 }


update : String -> List String -> State -> State
update newQuery list state =
    let
        matches =
            list
                |> List.indexedMap (,)
                |> List.filter (\( index, item ) -> String.contains newQuery item)

        firstMatchingIndex =
            case List.head matches of
                Nothing ->
                    Nothing

                Just ( index, _ ) ->
                    Just index
    in
        case firstMatchingIndex of
            Nothing ->
                { query = newQuery, selection = New newQuery }

            Just firstMatchingIndex ->
                { query = newQuery, selection = Index firstMatchingIndex }
