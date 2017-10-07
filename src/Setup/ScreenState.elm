module Setup.ScreenState exposing (..)

import Setup.Rpg.View exposing (RpgState)


type ScreenState
    = Configure
    | Continue
    | Rpg RpgState
