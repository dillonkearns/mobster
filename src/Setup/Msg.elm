module Setup.Msg exposing (..)

import Animation
import Dom
import Html5.DragDrop as DragDrop
import Ipc
import Keyboard.Combo
import Keyboard.Extra
import Roster.Operation exposing (MobsterOperation)
import Setup.InputField exposing (..)
import Window


type Msg
    = StartTimer
    | SkipBreak
    | OpenContinueScreen
    | StartBreak
    | ViewRpgNextUp
    | ToggleRotationScreen
    | ShowRotationScreen
    | SkipHotkey
    | StartRpgMode
    | UpdateRosterData MobsterOperation
    | CheckRpgBox Msg Bool
    | DomResult (Result Dom.Error ())
    | ChangeInput InputField String
    | SelectInputField String
    | OpenConfigure
    | NewTip Int
    | EnterRating Int
    | ComboMsg Keyboard.Combo.Msg
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
    | KeyPressed Bool Keyboard.Extra.Key
    | Animate Animation.Msg
    | WindowResized Window.Size
    | ToggleBetaUi


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
