module Roster.Presenter exposing (..)

import Array
import Roster.Data exposing (RosterData, nextIndex)


type alias DriverNavigator =
    { driver : Mobster
    , navigator : Mobster
    }


type Role
    = Driver
    | Navigator


type alias Mobster =
    { name : String, index : Int }


type alias MobsterWithRole =
    { name : String, role : Maybe Role, index : Int }


type alias Mobsters =
    List MobsterWithRole


nextDriverNavigator : RosterData -> DriverNavigator
nextDriverNavigator rosterData =
    let
        list =
            asMobsterList rosterData

        mobstersAsArray =
            Array.fromList list

        maybeDriver =
            Array.get rosterData.nextDriver mobstersAsArray

        driver =
            case maybeDriver of
                Just justDriver ->
                    justDriver

                Nothing ->
                    { name = "", index = -1 }

        navigatorIndex =
            nextIndex rosterData.nextDriver rosterData

        maybeNavigator =
            Array.get navigatorIndex mobstersAsArray

        navigator =
            case maybeNavigator of
                Just justNavigator ->
                    justNavigator

                Nothing ->
                    driver
    in
    { driver = driver
    , navigator = navigator
    }


mobsterListItemToMobster : DriverNavigator -> Int -> Roster.Data.Mobster -> MobsterWithRole
mobsterListItemToMobster driverNavigator index mobster =
    let
        role =
            if index == driverNavigator.driver.index then
                Just Driver
            else if index == driverNavigator.navigator.index then
                Just Navigator
            else
                Nothing
    in
    { name = mobster.name, role = role, index = index }


asMobsterList : RosterData -> List Mobster
asMobsterList rosterData =
    List.indexedMap (\index mobster -> { name = mobster.name, index = index }) rosterData.mobsters


mobsters : RosterData -> Mobsters
mobsters rosterData =
    List.indexedMap (mobsterListItemToMobster (nextDriverNavigator rosterData)) rosterData.mobsters
