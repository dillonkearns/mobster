// WARNING: Do not manually modify this file. It was generated using:
// https://github.com/dillonkearns/elm-typescript-interop
// Type definitions for Elm ports

export namespace Elm {
  namespace Timer.Main {
    export interface App {
      ports: {
        saveSettings: {
          subscribe(callback: (data: any) => void): void;
        };
        sendIpc: {
          subscribe(callback: (data: [string, any]) => void): void;
        };
        selectDuration: {
          subscribe(callback: (data: string) => void): void;
        };
        timeElapsed: {
          send(data: number): void;
        };
        breakDone: {
          send(data: number): void;
        };
        updateDownloaded: {
          send(data: string): void;
        };
        timerDone: {
          subscribe(callback: (data: number) => void): void;
        };
        breakTimerDone: {
          subscribe(callback: (data: number) => void): void;
        };
      };
    }
    export function init(options: {
      node?: HTMLElement | null;
      flags: any;
    }): Elm.Timer.Main.App;
  }
}
