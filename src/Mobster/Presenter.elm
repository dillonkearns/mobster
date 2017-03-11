module Mobster.Presenter exposing (..)

import Mobster.Data exposing (nextIndex, MobsterData)
import Array


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


nextDriverNavigator : MobsterData -> DriverNavigator
nextDriverNavigator mobsterData =
    let
        list =
            asMobsterList mobsterData

        mobstersAsArray =
            Array.fromList list

        maybeDriver =
            Array.get mobsterData.nextDriver mobstersAsArray

        driver =
            case maybeDriver of
                Just justDriver ->
                    justDriver

                Nothing ->
                    { name = "", index = -1 }

        navigatorIndex =
            nextIndex mobsterData.nextDriver mobsterData

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


mobsterListItemToMobster : DriverNavigator -> Int -> String -> MobsterWithRole
mobsterListItemToMobster driverNavigator index mobsterName =
    let
        role =
            if index == driverNavigator.driver.index then
                Just Driver
            else if index == driverNavigator.navigator.index then
                Just Navigator
            else
                Nothing
    in
        { name = mobsterName, role = role, index = index }


asMobsterList : MobsterData -> List Mobster
asMobsterList mobsterData =
    List.indexedMap (\index mobsterName -> { name = mobsterName, index = index }) mobsterData.mobsters


mobsters : MobsterData -> Mobsters
mobsters mobsterData =
    List.indexedMap (mobsterListItemToMobster (nextDriverNavigator mobsterData)) mobsterData.mobsters
