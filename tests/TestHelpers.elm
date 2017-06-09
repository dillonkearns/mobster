module TestHelpers exposing (..)

import Roster.Rpg as Rpg
import Roster.Data as RosterData


toMobsters : List String -> List RosterData.Mobster
toMobsters stringList =
    List.map (\name -> RosterData.Mobster name Rpg.init) stringList


toMobstersNoExperience : List String -> List RosterData.Mobster
toMobstersNoExperience stringList =
    List.map (\name -> RosterData.Mobster name (Rpg.RpgData [] [] [] [] [])) stringList
