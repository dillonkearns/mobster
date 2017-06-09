module TestHelpers exposing (..)

import Roster.Rpg as Rpg
import Roster.Data as MobsterData


toMobsters : List String -> List MobsterData.Mobster
toMobsters stringList =
    List.map (\name -> MobsterData.Mobster name Rpg.init) stringList


toMobstersNoExperience : List String -> List MobsterData.Mobster
toMobstersNoExperience stringList =
    List.map (\name -> MobsterData.Mobster name (Rpg.RpgData [] [] [] [] [])) stringList
