module GlobalShortcutTests exposing (suite)

import Expect
import GlobalShortcut
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "global shortcuts"
        [ test "non-ascii characters are invalid" <|
            \() ->
                GlobalShortcut.isInvalid "å"
                    |> Expect.equal True
        , test "numbers are valid" <|
            \() ->
                GlobalShortcut.isInvalid "3"
                    |> Expect.equal False
        , test "ascii characters are valid" <|
            \() ->
                GlobalShortcut.isInvalid "x"
                    |> Expect.equal False
        ]
