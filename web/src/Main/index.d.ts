// WARNING: Do not manually modify this file. It was generated using:
// https://github.com/dillonkearns/elm-typescript-interop
// Type definitions for Elm ports
export as namespace Elm


export interface App {
  ports: {

  }
}
    

export namespace Main {
  export function fullscreen(flags: { os: string }): App
  export function embed(node: HTMLElement | null, flags: { os: string }): App
}