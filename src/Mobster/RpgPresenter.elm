module Mobster.RpgPresenter exposing (..)

import Mobster.Data exposing (MobsterData)
import Mobster.Rpg exposing (Experience)


type RpgRole
    = Driver
    | Navigator
    | Researcher
    | Sponsor


type alias RpgMobster =
    { role : RpgRole
    , experience : Experience
    , name : String
    , index : Int
    }


present : MobsterData -> List RpgMobster
present mobsterData =
    []
