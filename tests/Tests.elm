module Tests exposing (..)

import BreakTests
import MobsterTests
import SettingsDecodeTests
import Test exposing (..)
import TimerTests


all : Test
all =
    describe "tests"
        [ TimerTests.all
        , MobsterTests.all
        , BreakTests.all
        , SettingsDecodeTests.all
        ]
