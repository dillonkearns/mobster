module Setup.ScreenState exposing
    ( RpgState(..)
    , ScreenState(..)
    )


type ScreenState
    = Configure
    | Continue { breakSecondsLeft : Int }
    | Rpg RpgState


type RpgState
    = Checklist
    | NextUp
