// Type definitions for Elm
// Project: https://github.com/dillonkearns/elm-typescript
// Definitions by: Dillon Kearns <https://github.com/dillonkearns>
export as namespace Elm

export interface App {
  ports: {
    saveSettings: {
      subscribe(callback: (data: any) => void): void
    }
    sendIpc: {
      subscribe(callback: (data: [string, any]) => void): void
    }
    selectDuration: {
      subscribe(callback: (data: string) => void): void
    }
    timeElapsed: {
      send(data: number): void
    }
    breakDone: {
      send(data: number): void
    }
    updateDownloaded: {
      send(data: string): void
    }
  }
}

export namespace Setup.Main {
  export function fullscreen(flags: {
    onMac: boolean
    isLocal: boolean
    settings: any
  }): App
  export function embed(
    node: HTMLElement | null,
    flags: { onMac: boolean; isLocal: boolean; settings: any }
  ): App
}
