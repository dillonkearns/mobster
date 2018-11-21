module ListHelpers exposing
    ( compact
    , insertAbove
    , insertAt
    , insertBelow
    , mapToJust
    , move
    , removeAndGet
    , removeFromListAt
    )

import Array
import Array.Extra


move : Int -> Int -> List a -> List a
move fromIndex toIndex mobsters =
    let
        mobsterToMove =
            mobsters
                |> Array.fromList
                |> Array.get fromIndex
    in
    mobsters
        |> mapToJust
        |> Array.fromList
        |> Array.set fromIndex Nothing
        |> insertAt mobsterToMove toIndex (fromIndex > toIndex)
        |> Array.toList
        |> compact


removeAndGet : Int -> List a -> ( Maybe a, List a )
removeAndGet index list =
    let
        listAsArray =
            list
                |> Array.fromList

        removedMobster =
            listAsArray
                |> Array.get index

        listWithoutMobster =
            listAsArray
                |> Array.Extra.removeAt index
                |> Array.toList
    in
    ( removedMobster, listWithoutMobster )


removeFromListAt : Int -> List a -> List a
removeFromListAt index list =
    list
        |> Array.fromList
        |> Array.Extra.removeAt index
        |> Array.toList


replaceSlice : a -> Int -> Int -> Array.Array a -> Array.Array a
replaceSlice substitution start end asArray =
    let
        part1 =
            Array.slice 0 start asArray

        part2 =
            [ substitution ] |> Array.fromList

        part3 =
            Array.slice end (Array.length asArray) asArray
    in
    Array.append (Array.append part1 part2) part3


insertBelow : a -> Int -> Array.Array a -> Array.Array a
insertBelow insert pos string =
    insertAbove insert (pos + 1) string


insertAbove : a -> Int -> Array.Array a -> Array.Array a
insertAbove insert pos string =
    replaceSlice insert pos pos string


insertAt : a -> Int -> Bool -> Array.Array a -> Array.Array a
insertAt insert pos above string =
    if above then
        insertAbove insert pos string

    else
        insertBelow insert pos string


compact : List (Maybe a) -> List a
compact list =
    List.filterMap identity list


mapToJust : List a -> List (Maybe a)
mapToJust aList =
    aList |> List.map (\item -> Just item)
