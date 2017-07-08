module ValidationsTests exposing (suite)

import Test exposing (..)
import Expect
import Setup.Validations as Validations


suite : Test
suite =
    describe "validations"
        [ test "gives bottom of range if below min" <|
            \() ->
                Expect.equal (Validations.parseIntWithinRange ( -5, 150 ) "-10") -5
        , test "gives top of range if above max" <|
            \() ->
                Expect.equal (Validations.parseIntWithinRange ( -5, 150 ) "1234") 150
        , test "gives parsed number if within range" <|
            \() ->
                Expect.equal (Validations.parseIntWithinRange ( -1000, 1000 ) "20") 20
        , test "parse invalid number" <|
            \() ->
                Expect.equal (Validations.parseIntWithinRange ( -1000, 1000 ) "20asdf") -1000
        ]
