module Setup.Msg exposing (Direction(..), DragId(..), DropArea(..), InputField(..), Msg(..), StringInputField(..))

-- import Keyboard.Combo

import Animation
import Browser
import Browser.Dom
import Html5.DragDrop as DragDrop
import Ipc
import Keyboard
import Roster.Operation exposing (MobsterOperation)
import Roster.RpgRole exposing (RpgRole)
import Setup.InputField exposing (..)
import Time


type Msg
    = StartTimer
    | SkipBreak
    | GoToRosterShortcut
    | GoToTipScreenShortcut
    | OpenContinueScreen
    | ViewRpgNextUp
    | SkipHotkey
    | StartRpgMode
    | UpdateRosterData MobsterOperation
    | CheckRpgBox { index : Int, role : RpgRole } Int
    | DomResult (Result Browser.Dom.Error ())
    | ChangeInput InputField String
    | SelectInputField String
    | OpenConfigure
    | NewTip Int
      -- | ComboMsg Keyboard.Combo.Msg
    | ShuffleMobsters
    | RandomizeMobsters
    | TimeElapsed Int
    | BreakDone Int
    | UpdateAvailable String
    | ResetBreakData
    | RotateInHotkey Int
    | RotateOutHotkey Int
    | DragDropMsg (DragDrop.Msg DragId DropArea)
    | SendIpc Ipc.Msg
    | QuickRotateAdd
    | QuickRotateMove Direction
    | KeyPressed Bool Keyboard.Key
    | Animate Animation.Msg
    | WindowResized Int Int
    | MinuteElapsed Time.Posix
    | BreakSecondElapsed Time.Posix
    | ShuffleHover Bool


type Direction
    = Previous
    | Next


type InputField
    = IntField IntInputField
    | StringField StringInputField


type StringInputField
    = ShowHideShortcut
    | NewMobster
    | QuickRotateQuery


type DragId
    = ActiveMobster Int
    | InactiveMobster Int


type DropArea
    = DropBench
    | DropActiveMobster Int
