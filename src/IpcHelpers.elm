module IpcHelpers exposing (..)

import Ipc
import Setup.Msg as Msg exposing (Msg)
import Tip


openTipUrl : Tip.Tip -> Msg
openTipUrl tip =
    Msg.SendIpc (Ipc.OpenExternalUrl tip.url)
