module OsTests exposing (suite)

import Expect
import Os
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "os tests"
        [ [ "MacIntel"
          , "MacPPC"
          , "Mac OS X"
          ]
            |> expectOs Os.Mac
        , [ "Win32"
          , "Windows XP"
          , "Windows 8"
          , "Windows 10.0"
          ]
            |> expectOs Os.Windows
        , [ "Linux" ]
            |> expectOs Os.Linux
        , [ "iPhone", "FreeBSD i386" ]
            |> expectOs Os.Other
        ]


expectOs : Os.Os -> List String -> Test
expectOs expectedOs platformStrings =
    platformStrings
        |> List.map
            (\platformString ->
                test platformString
                    (\() -> Os.fromString platformString |> Expect.equal expectedOs)
            )
        |> describe ("extracts to " ++ toString expectedOs)
