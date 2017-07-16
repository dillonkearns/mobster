module IpcHelpers exposing (..)

import Ipc
import Json.Encode as Encode
import Setup.Msg as Msg exposing (Msg)
import Tip


openTipUrl : Tip.Tip -> Msg
openTipUrl tip =
    Msg.SendIpc Ipc.OpenExternalUrl (Encode.string tip.url)
