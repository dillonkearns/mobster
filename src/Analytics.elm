module Analytics exposing (trackEvent)

import Basics.Extra exposing ((=>))
import Ipc
import IpcSerializer
import Json.Encode as Encode
import Setup.Msg as Msg exposing (Msg)
import Setup.Ports


trackEvent :
    { category : String, action : String, label : Maybe String, value : Maybe Int }
    -> ( model, Cmd Msg )
    -> ( model, Cmd Msg )
trackEvent eventDetails modelCmd =
    modelCmd
        |> withIpcMsg
            (Ipc.TrackEvent
                (Encode.object
                    [ "ec" => Encode.string eventDetails.category
                    , "ea" => Encode.string eventDetails.action
                    , "el" => encodeMaybe Encode.string eventDetails.label
                    , "ev" => encodeMaybe Encode.int eventDetails.value
                    ]
                )
            )


withIpcMsg : Ipc.Msg -> ( model, Cmd Msg ) -> ( model, Cmd Msg )
withIpcMsg msgIpc ( model, cmd ) =
    model ! [ cmd, sendIpcCmd msgIpc ]


sendIpcCmd : Ipc.Msg -> Cmd msg
sendIpcCmd ipcMsg =
    ipcMsg
        |> IpcSerializer.serialize
        |> Setup.Ports.sendIpc


encodeMaybe : (a -> Encode.Value) -> Maybe a -> Encode.Value
encodeMaybe encodeFunction maybeValue =
    case maybeValue of
        Just value ->
            encodeFunction value

        Nothing ->
            Encode.null
