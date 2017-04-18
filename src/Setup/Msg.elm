module Setup.Msg exposing (..)

import Dom
import Html5.DragDrop as DragDrop
import Json.Encode as Encode
import Keyboard.Combo
import Mobster.Operation exposing (MobsterOperation)
import Setup.InputField exposing (..)
import Ipc


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
    | DomFocusResult (Result Dom.Error ())
    | ChangeInput InputField String
    | SelectDurationInput
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


type InputField
    = IntField IntInputField
    | StringField StringInputField


type StringInputField
    = Experiment
    | ShowHideShortcut
    | NewMobster


type DragId
    = ActiveMobster Int
    | InactiveMobster Int


type DropArea
    = DropBench
    | DropActiveMobster Int
