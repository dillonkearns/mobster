module Setup.ScreenState
    exposing
        ( RpgState(Checklist, NextUp)
        , ScreenState(Configure, Continue, Rpg)
        )


type ScreenState
    = Configure
    | Continue { breakSecondsLeft : Int }
    | Rpg RpgState


type RpgState
    = Checklist
    | NextUp
