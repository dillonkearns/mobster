module Tests exposing (..)

import BreakTests
import MobsterDataTests
import MobsterOperationTests
import MobsterPresenterTests
import RpgPresenterTests
import RpgTests
import SettingsDecodeTests
import Test exposing (..)
import TimerTests
import ValidationsTests
import TimerFlagsTests


all : Test
all =
    describe "tests"
        [ TimerTests.all
        , MobsterDataTests.all
        , MobsterOperationTests.all
        , MobsterPresenterTests.all
        , RpgPresenterTests.all
        , MobsterPresenterTests.all
        , BreakTests.all
        , SettingsDecodeTests.all
        , RpgTests.all
        , ValidationsTests.all
        , TimerFlagsTests.all
        ]
