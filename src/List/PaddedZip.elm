module List.PaddedZip exposing (paddedZip)


paddedZip list1 list2 =
    let
        list1Maybes =
            list1 |> List.map (\item -> Just item)

        list2Maybes =
            list2 |> List.map (\item -> Just item)

        differenceInLength =
            List.length list1 - List.length list2

        list1Padding =
            if differenceInLength < 0 then
                differenceInLength * -1
            else
                0

        list2Padding =
            if differenceInLength > 0 then
                differenceInLength
            else
                0

        paddedList1Maybes =
            list1Maybes ++ List.repeat list1Padding Nothing

        paddedList2Maybes =
            list2Maybes ++ List.repeat list2Padding Nothing
    in
    List.map2 (,) paddedList1Maybes paddedList2Maybes
