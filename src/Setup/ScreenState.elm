module Setup.ScreenState exposing (ScreenState(Configure, Continue, Rpg))

import Setup.Rpg.View exposing (RpgState)


type ScreenState
    = Configure
    | Continue
    | Rpg RpgState
