module Setup.Msg exposing (..)

import Animation
import Dom
import Html5.DragDrop as DragDrop
import Ipc
import Json.Encode as Encode
import Keyboard.Combo
import Keyboard.Extra
import Mobster.Operation exposing (MobsterOperation)
import Setup.InputField exposing (..)


type Msg
    = StartTimer
    | SkipBreak
    | StartBreak
    | ViewRpgNextUp
    | ShowRotationScreen
    | SkipHotkey
    | StartRpgMode
    | UpdateMobsterData MobsterOperation
    | CheckRpgBox Msg Bool
    | AddMobster
    | ClickAddMobster
    | DomResult (Result Dom.Error ())
    | ChangeInput InputField String
    | SelectInputField String
    | OpenConfigure
    | NewTip Int
    | SetExperiment
    | ChangeExperiment
    | EnterRating Int
    | ComboMsg Keyboard.Combo.Msg
    | ShuffleMobsters
    | TimeElapsed Int
    | BreakDone Int
    | UpdateAvailable String
    | ResetBreakData
    | RotateInHotkey Int
    | RotateOutHotkey Int
    | DragDropMsg (DragDrop.Msg DragId DropArea)
    | SendIpc Ipc.Msg Encode.Value
    | NoOp
    | QuickRotateAdd
    | QuickRotateMove Direction
    | KeyPressed Bool Keyboard.Extra.Key
    | Animate Animation.Msg


type Direction
    = Previous
    | Next


type InputField
    = IntField IntInputField
    | StringField StringInputField


type StringInputField
    = Experiment
    | ShowHideShortcut
    | NewMobster
    | QuickRotateQuery


type DragId
    = ActiveMobster Int
    | InactiveMobster Int


type DropArea
    = DropBench
    | DropActiveMobster Int
