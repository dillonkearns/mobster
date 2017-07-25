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

        ChangeShortcut newShortcut ->
            ( "ChangeShortcut", Encode.string newShortcut )

        OpenExternalUrl url ->
            ( "OpenExternalUrl", Encode.string url )

        StartTimer flags ->
            ( "StartTimer", flags )

        SaveActiveMobstersFile rosterString ->
            ( "SaveActiveMobstersFile", Encode.string rosterString )

        NotifySettingsDecodeFailed errorString ->
            ( "NotifySettingsDecodeFailed", Encode.string errorString )
