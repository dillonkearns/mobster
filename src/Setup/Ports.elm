port module Setup.Ports exposing (breakDone, saveSettings, selectDuration, sendIpc, timeElapsed, updateDownloaded)

import Json.Encode as Encode


port saveSettings : Encode.Value -> Cmd msg


port sendIpc : ( String, Encode.Value ) -> Cmd msg


port selectDuration : String -> Cmd msg


port timeElapsed : (Int -> msg) -> Sub msg


port breakDone : (Int -> msg) -> Sub msg


port updateDownloaded : (String -> msg) -> Sub msg
