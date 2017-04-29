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
    case state.selection of
        All ->
            state

        New string ->
            let
                allMatches =
                    matches list state

                firstMatch =
                    allMatches
                        |> List.head
            in
                case firstMatch of
                    Just firstMatchIndex ->
                        { state | selection = Index firstMatchIndex }

                    Nothing ->
                        state

        Index int ->
            let
                allMatches =
                    matches list state

                nextMatch =
                    allMatches
                        |> List.filter (\index -> index > int)
                        |> List.head
            in
                case nextMatch of
                    Just nextMatchIndex ->
                        { state | selection = Index nextMatchIndex }

                    Nothing ->
                        { state | selection = New state.query }


matches : List String -> State -> List Int
matches list state =
    list
        |> List.indexedMap (,)
        |> List.filter (\( index, item ) -> String.contains (String.toLower state.query) (String.toLower item))
        |> List.map (\( index, _ ) -> index)


update : String -> List String -> State -> State
update newQuery list state =
    let
        matches =
            list
                |> List.indexedMap (,)
                |> List.filter (\( index, item ) -> String.contains (String.toLower newQuery) (String.toLower item))

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
