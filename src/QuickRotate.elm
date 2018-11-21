module QuickRotate exposing
    ( EntrySelection(..)
    , Selection(..)
    , State
    , init
    , matches
    , next
    , previous
    , selectionTypeFor
    , update
    )

import List.Extra


type Selection
    = All
    | New String
    | Index Int


type EntrySelection
    = Matches
    | Selected
    | NoMatch


selectionTypeFor : Int -> List Int -> Selection -> EntrySelection
selectionTypeFor index matches_ selection =
    if Index index == selection then
        Selected

    else if selection == All then
        NoMatch

    else
        let
            match =
                matches_
                    |> List.member index
        in
        if match then
            Matches

        else
            NoMatch


type alias State =
    { selection : Selection
    , query : String
    }


init : State
init =
    { selection = All
    , query = ""
    }


previous : List String -> State -> State
previous list state =
    let
        allMatches =
            matches list state
    in
    case state.selection of
        All ->
            if List.isEmpty list then
                state

            else
                { state | selection = Index (List.length list - 1) }

        New _ ->
            let
                firstMatch =
                    allMatches
                        |> List.Extra.last
            in
            case firstMatch of
                Just firstMatchIndex ->
                    { state | selection = Index firstMatchIndex }

                Nothing ->
                    state

        Index int ->
            let
                nextMatch =
                    allMatches
                        |> List.filter (\index -> index < int)
                        |> List.Extra.last
            in
            case nextMatch of
                Just nextMatchIndex ->
                    { state | selection = Index nextMatchIndex }

                Nothing ->
                    if state.query == "" then
                        previous list { state | selection = New state.query }

                    else
                        { state | selection = New state.query }


next : List String -> State -> State
next list state =
    let
        allMatches =
            matches list state
    in
    case state.selection of
        All ->
            if List.isEmpty list then
                state

            else
                { state | selection = Index 0 }

        New string ->
            let
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
                nextMatch =
                    allMatches
                        |> List.filter (\index -> index > int)
                        |> List.head
            in
            case nextMatch of
                Just nextMatchIndex ->
                    { state | selection = Index nextMatchIndex }

                Nothing ->
                    if state.query == "" then
                        next list { state | selection = New state.query }

                    else
                        { state | selection = New state.query }


matches : List String -> State -> List Int
matches list state =
    list
        |> List.indexedMap (\a b -> ( a, b ))
        |> List.filter (\( index, item ) -> String.contains (String.toLower state.query) (String.toLower item))
        |> List.map (\( index, _ ) -> index)


update : String -> List String -> State -> State
update newQuery list state =
    let
        matches_ =
            list
                |> List.indexedMap (\a b -> ( a, b ))
                |> List.filter (\( index, item ) -> String.contains (String.toLower newQuery) (String.toLower item))

        firstMatchingIndex =
            case List.head matches_ of
                Nothing ->
                    Nothing

                Just ( index, _ ) ->
                    Just index
    in
    if newQuery == "" then
        { query = newQuery, selection = All }

    else
        case firstMatchingIndex of
            Nothing ->
                { query = newQuery, selection = New newQuery }

            Just firstMatchingIndex_ ->
                { query = newQuery, selection = Index firstMatchingIndex_ }
