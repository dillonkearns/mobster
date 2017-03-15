module TestHelpers exposing (..)

import Mobster.Rpg as Rpg
import Mobster.Data as MobsterData


toMobsters : List String -> List MobsterData.Mobster
toMobsters stringList =
    List.map (\name -> MobsterData.Mobster name Rpg.init) stringList
