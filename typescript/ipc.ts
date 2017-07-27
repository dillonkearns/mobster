import { ipcMain } from 'electron'

class Ipc {
  static setupIpcMessageHandler(onIpcMessage: (elmIpc: ElmIpc) => any) {
    ipcMain.on('elm-electron-ipc', (event: any, payload: any) => {
      onIpcMessage(payload)
    })
  }
}

export { Ipc, ElmIpc }

type ElmIpc =
  | ShowFeedbackForm
  | ShowScriptInstallInstructions
  | Hide
  | Quit
  | QuitAndInstall
  | ChangeShortcut
  | OpenExternalUrl
  | StartTimer
  | SaveActiveMobstersFile
  | NotifySettingsDecodeFailed

interface ShowFeedbackForm {
  message: 'ShowFeedbackForm'
}

interface ShowScriptInstallInstructions {
  message: 'ShowScriptInstallInstructions'
}

interface Hide {
  message: 'Hide'
}

interface Quit {
  message: 'Quit'
}

interface QuitAndInstall {
  message: 'QuitAndInstall'
}

interface ChangeShortcut {
  message: 'ChangeShortcut'
  data: string
}

interface OpenExternalUrl {
  message: 'OpenExternalUrl'
  data: string
}

interface StartTimer {
  message: 'StartTimer'
  data: any
}

interface SaveActiveMobstersFile {
  message: 'SaveActiveMobstersFile'
  data: string
}

interface NotifySettingsDecodeFailed {
  message: 'NotifySettingsDecodeFailed'
  data: string
}
