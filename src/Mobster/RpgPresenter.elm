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
    List.indexedMap toRpgMobster mobsterData.mobsters


toRpgMobster index mobsterName =
    RpgMobster (getRoleForIndex index) [] mobsterName index


getRoleForIndex index =
    if index == 0 then
        Driver
    else
        Navigator
