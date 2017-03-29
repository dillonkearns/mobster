module Setup.View exposing (..)

import Setup.Rpg.View exposing (..)


type ScreenState
    = Configure
    | Continue Bool
    | Rpg RpgState
