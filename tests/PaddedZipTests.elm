module PaddedZipTests exposing (all)

import Expect
import List.PaddedZip
import Test exposing (..)


all : Test
all =
    describe "padded zip"
        [ test "both empty lists" <|
            \() ->
                List.PaddedZip.paddedZip [] []
                    |> Expect.equal []
        , test "non-empty lists of same size" <|
            \() ->
                List.PaddedZip.paddedZip [ 1, 2 ] [ "a", "b" ]
                    |> Expect.equal
                        [ ( Just 1, Just "a" )
                        , ( Just 2, Just "b" )
                        ]
        , test "non-empty lists where first is longer" <|
            \() ->
                List.PaddedZip.paddedZip [ 1, 2, 3 ] [ "a", "b" ]
                    |> Expect.equal
                        [ ( Just 1, Just "a" )
                        , ( Just 2, Just "b" )
                        , ( Just 3, Nothing )
                        ]
        , test "non-empty lists where second is longer" <|
            \() ->
                List.PaddedZip.paddedZip [ 1, 2 ] [ "a", "b", "c" ]
                    |> Expect.equal
                        [ ( Just 1, Just "a" )
                        , ( Just 2, Just "b" )
                        , ( Nothing, Just "c" )
                        ]
        , test "long, unequal length lists" <|
            \() ->
                List.PaddedZip.paddedZip [ 1, 2, 3, 4, 5, 6 ] [ "a", "b", "c" ]
                    |> Expect.equal
                        [ ( Just 1, Just "a" )
                        , ( Just 2, Just "b" )
                        , ( Just 3, Just "c" )
                        , ( Just 4, Nothing )
                        , ( Just 5, Nothing )
                        , ( Just 6, Nothing )
                        ]
        ]
