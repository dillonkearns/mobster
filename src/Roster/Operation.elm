module Roster.Operation exposing (MobsterOperation(..), add, completeGoalInRpgData, updateMoblist)

import Array
import ListHelpers
import Roster.Data exposing (Mobster, RosterData, nextIndex, previousIndex)
import Roster.Rpg as Rpg exposing (RpgData)
import Roster.RpgRole exposing (..)


type MobsterOperation
    = Move Int Int
    | Remove Int
    | SetNextDriver Int
    | NextTurn
    | RewindTurn
    | Bench Int
    | RotateIn Int
    | Add String
    | Reorder (List Mobster)
    | CompleteGoal Int RpgRole Int


updateMoblist : MobsterOperation -> RosterData -> RosterData
updateMoblist mobsterOperation rosterData =
    case mobsterOperation of
        Move fromIndex toIndex ->
            let
                updatedMobsters =
                    ListHelpers.move fromIndex toIndex rosterData.mobsters
            in
            { rosterData | mobsters = updatedMobsters }

        Remove mobsterIndex ->
            remove mobsterIndex rosterData

        SetNextDriver index ->
            setNextDriver index rosterData

        NextTurn ->
            setNextDriver (nextIndex rosterData.nextDriver rosterData) rosterData

        RewindTurn ->
            setNextDriver (previousIndex rosterData.nextDriver rosterData) rosterData

        Bench mobsterIndex ->
            bench mobsterIndex rosterData

        RotateIn mobsterIndex ->
            rotateIn mobsterIndex rosterData

        Add mobsterName ->
            add mobsterName rosterData

        Reorder reorderedMobsters ->
            reorder reorderedMobsters rosterData

        CompleteGoal mobsterIndex role goalIndex ->
            rosterData
                |> completeGoal mobsterIndex role goalIndex


mobsterWithCompletedGoal : Int -> RpgRole -> Int -> List Mobster -> Maybe Mobster
mobsterWithCompletedGoal mobsterIndex role goalIndex rosterData =
    let
        maybeMobster =
            rosterData
                |> Array.fromList
                |> Array.get mobsterIndex
    in
    case maybeMobster of
        Just mobster ->
            let
                updatedRpgData =
                    completeGoalInRpgData role goalIndex mobster.rpgData
            in
            Just { mobster | rpgData = updatedRpgData }

        Nothing ->
            Nothing


completeGoal : Int -> RpgRole -> Int -> Roster.Data.RosterData -> RosterData
completeGoal mobsterIndex role goalIndex rosterData =
    let
        withGoal =
            mobsterWithCompletedGoal mobsterIndex role goalIndex rosterData.mobsters

        updatedMobsters =
            case withGoal of
                Just mobsterWithGoal ->
                    rosterData.mobsters
                        |> Array.fromList
                        |> Array.set mobsterIndex mobsterWithGoal
                        |> Array.toList

                Nothing ->
                    rosterData.mobsters
    in
    { rosterData | mobsters = updatedMobsters }


add : String -> RosterData -> RosterData
add mobster list =
    { list | mobsters = List.append list.mobsters [ { name = mobster, rpgData = Rpg.init } ] }


rotateIn : Int -> RosterData -> RosterData
rotateIn index list =
    let
        ( maybeMobsterToMove, inactiveWithoutNewlyActive ) =
            ListHelpers.removeAndGet index list.inactiveMobsters
    in
    case maybeMobsterToMove of
        Just mobsterToMove ->
            let
                activeWithNewlyActive =
                    list.mobsters
                        |> Array.fromList
                        |> ListHelpers.insertAt mobsterToMove list.nextDriver False
                        |> Array.toList
            in
            { list | mobsters = activeWithNewlyActive, inactiveMobsters = inactiveWithoutNewlyActive }

        Nothing ->
            list


bench : Int -> RosterData -> RosterData
bench index list =
    let
        ( maybeMobsterToBench, activeWithoutBenchedMobster ) =
            ListHelpers.removeAndGet index list.mobsters
    in
    case maybeMobsterToBench of
        Just mobsterToBench ->
            let
                updatedInactive =
                    List.append list.inactiveMobsters [ mobsterToBench ]
            in
            { list
                | mobsters = activeWithoutBenchedMobster
                , inactiveMobsters = updatedInactive
            }
                |> setNextDriverInBounds

        Nothing ->
            list


remove : Int -> RosterData -> RosterData
remove index list =
    { list | inactiveMobsters = ListHelpers.removeFromListAt index list.inactiveMobsters }


setNextDriver : Int -> RosterData -> RosterData
setNextDriver newDriver rosterData =
    { rosterData | nextDriver = newDriver }


reorder : List Roster.Data.Mobster -> RosterData -> RosterData
reorder shuffledMobsters rosterData =
    { rosterData | mobsters = shuffledMobsters, nextDriver = 0 }


setNextDriverInBounds : RosterData -> RosterData
setNextDriverInBounds rosterData =
    let
        maxDriverIndex =
            List.length rosterData.mobsters - 1

        indexInBounds =
            if rosterData.nextDriver > maxDriverIndex && rosterData.nextDriver > 0 then
                0
            else
                rosterData.nextDriver
    in
    { rosterData | nextDriver = indexInBounds }


completeGoalInRpgData : RpgRole -> Int -> RpgData -> RpgData
completeGoalInRpgData role goalIndex rpgData =
    let
        experience =
            case role of
                Driver ->
                    rpgData.driver

                Navigator ->
                    rpgData.navigator

                Researcher ->
                    rpgData.researcher

                Sponsor ->
                    rpgData.sponsor

                Roster.RpgRole.Mobber ->
                    rpgData.mobber

        goal =
            goalFromIndex goalIndex experience

        updatedExperience =
            experience
                |> Array.fromList
                |> Array.set goalIndex (completeGoal2 goal)
                |> Array.toList

        updatedRpgData =
            case role of
                Driver ->
                    { rpgData | driver = updatedExperience }

                Navigator ->
                    { rpgData | navigator = updatedExperience }

                Mobber ->
                    { rpgData | mobber = updatedExperience }

                Researcher ->
                    { rpgData | researcher = updatedExperience }

                Sponsor ->
                    { rpgData | sponsor = updatedExperience }
    in
    updatedRpgData


completeGoal2 : { goal | complete : Bool } -> { goal | complete : Bool }
completeGoal2 goal =
    { goal | complete = True }


goalFromIndex : Int -> List Rpg.Goal -> Rpg.Goal
goalFromIndex goalIndex experience =
    experience
        |> Array.fromList
        |> Array.get goalIndex
        |> Maybe.withDefault { description = "", complete = True }
