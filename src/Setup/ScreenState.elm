module Setup.ScreenState
    exposing
        ( RpgState(Checklist, NextUp)
        , ScreenState(Configure, Continue, Rpg)
        )


type ScreenState
    = Configure
    | Continue
    | Rpg RpgState


type RpgState
    = Checklist
    | NextUp
