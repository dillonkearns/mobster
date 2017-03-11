module Tests exposing (..)

import BreakTests
import MobsterDataTests
import MobsterOperationTests
import MobsterPresenterTests
import SettingsDecodeTests
import Test exposing (..)
import TimerTests


all : Test
all =
    describe "tests"
        [ TimerTests.all
        , MobsterDataTests.all
        , MobsterOperationTests.all
        , MobsterPresenterTests.all
        , BreakTests.all
        , SettingsDecodeTests.all
        ]
