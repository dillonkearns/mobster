module Tests exposing (..)

import BreakTests
import MobsterTests
import MobsterOperationTests
import SettingsDecodeTests
import Test exposing (..)
import TimerTests


all : Test
all =
    describe "tests"
        [ TimerTests.all
        , MobsterTests.all
        , MobsterOperationTests.all
        , BreakTests.all
        , SettingsDecodeTests.all
        ]
