module IpcSerializer exposing (serialize)

import Ipc exposing (Msg(..))
import Json.Encode as Encode


serialize : Msg -> ( String, Encode.Value )
serialize msg =
    case msg of
        ShowFeedbackForm ->
            ( "ShowFeedbackForm", Encode.null )

        ShowScriptInstallInstructions ->
            ( "ShowScriptInstallInstructions", Encode.null )

        Hide ->
            ( "Hide", Encode.null )

        Quit ->
            ( "Quit", Encode.null )

        QuitAndInstall ->
            ( "QuitAndInstall", Encode.null )

        ChangeShortcut string ->
            ( "ChangeShortcut", Encode.string string )

        OpenExternalUrl string ->
            ( "OpenExternalUrl", Encode.string string )

        StartTimer value ->
            ( "StartTimer", value )

        SaveActiveMobstersFile string ->
            ( "SaveActiveMobstersFile", Encode.string string )

        NotifySettingsDecodeFailed string ->
            ( "NotifySettingsDecodeFailed", Encode.string string )

        TrackEvent value ->
            ( "TrackEvent", value )

        TrackPage string ->
            ( "TrackPage", Encode.string string )
