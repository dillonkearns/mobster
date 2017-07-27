module Ipc exposing (..)

import Json.Encode as Encode


type Msg
    = ShowFeedbackForm
    | ShowScriptInstallInstructions
    | Hide
    | Quit
    | QuitAndInstall
    | ChangeShortcut String
    | OpenExternalUrl String
    | StartTimer Encode.Value
    | SaveActiveMobstersFile String
    | NotifySettingsDecodeFailed String
