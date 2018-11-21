module Timer.Msg exposing (Msg(..))

import Time


type Msg
    = Tick Time.Posix
