module Analytics exposing (Event, trackEvent, trackOperation, trackPage)

import Basics.Extra exposing ((=>))
import Ipc
import IpcSerializer
import Json.Encode as Encode
import Roster.Operation as MobsterOperation exposing (MobsterOperation)
import Setup.Msg as Msg exposing (Msg)
import Setup.Ports
import Setup.Rpg.View
import Setup.View exposing (ScreenState)


type alias Event =
    { category : String, action : String, label : Maybe String, value : Maybe Int }


trackEvent : Event -> ( model, Cmd Msg ) -> ( model, Cmd Msg )
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


trackOperation : MobsterOperation -> ( model, Cmd Msg ) -> ( model, Cmd Msg )
trackOperation mobsterOperation modelCmd =
    modelCmd
        |> trackEvent (operationToEvent mobsterOperation)


operationToEvent : MobsterOperation -> Event
operationToEvent mobsterOperation =
    case mobsterOperation of
        MobsterOperation.Move from to ->
            { category = "roster", action = "move", label = Just (toString from ++ "-" ++ toString to), value = Nothing }

        MobsterOperation.Remove index ->
            { category = "roster", action = "remove", label = Nothing, value = Just index }

        MobsterOperation.SetNextDriver index ->
            { category = "roster", action = "set-next-driver", label = Nothing, value = Just index }

        MobsterOperation.NextTurn ->
            { category = "roster", action = "next-turn", label = Nothing, value = Nothing }

        MobsterOperation.RewindTurn ->
            { category = "roster", action = "rewind-turn", label = Nothing, value = Nothing }

        MobsterOperation.Bench index ->
            { category = "roster", action = "bench", label = Nothing, value = Just index }

        MobsterOperation.RotateIn index ->
            { category = "roster", action = "rotate-in", label = Nothing, value = Just index }

        MobsterOperation.Add string ->
            { category = "roster", action = "add", label = Nothing, value = Nothing }

        MobsterOperation.Reorder mobsterList ->
            { category = "roster", action = "reorder", label = Nothing, value = Nothing }

        MobsterOperation.CompleteGoal mobsterIndex role goalIndex ->
            { category = "roster"
            , action = "complete-goal"
            , label = Just (toString role ++ "[" ++ toString goalIndex ++ "]")
            , value = Nothing
            }


trackPage : ScreenState -> { model | showBetaUi : Bool } -> Cmd Msg
trackPage newScreenState model =
    sendIpcCmd (Ipc.TrackPage (screenToString newScreenState model))


screenToString : ScreenState -> { model | showBetaUi : Bool } -> String
screenToString newScreenState showBetaUi =
    case newScreenState of
        Setup.View.Configure ->
            "configure"

        Setup.View.Continue bool ->
            "continue"

        Setup.View.Rpg rpgState ->
            case rpgState of
                Setup.Rpg.View.Checklist ->
                    "rpg-checklist"

                Setup.Rpg.View.NextUp ->
                    "rpg-next-up"


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
