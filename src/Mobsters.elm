module Mobsters exposing (..)

import Array


type alias Mobster =
    String


type alias MobsterList =
    { mobsters : List Mobster, nextDriver : Int }


empty : MobsterList
empty =
    { mobsters = [], nextDriver = 0 }


add : String -> MobsterList -> MobsterList
add mobster list =
    { list | mobsters = (List.append list.mobsters [ mobster ]) }


type alias DriverNavigator =
    { driver : String
    , navigator : String
    }


nextDriverNavigator : MobsterList -> DriverNavigator
nextDriverNavigator list =
    let
        mobstersAsArray =
            Array.fromList list.mobsters

        maybeDriver =
            Array.get list.nextDriver mobstersAsArray

        driver =
            case maybeDriver of
                Just justDriver ->
                    justDriver

                Nothing ->
                    ""

        maybeNavigator =
            Array.get (nextIndex list.nextDriver list) mobstersAsArray

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


nextIndex : Int -> MobsterList -> Int
nextIndex currentIndex mobsterList =
    let
        mobSize =
            List.length mobsterList.mobsters

        index =
            if mobSize == 0 then
                0
            else
                (currentIndex + 1) % mobSize
    in
        index


rotate : MobsterList -> MobsterList
rotate mobsterList =
    { mobsterList | nextDriver = (nextIndex mobsterList.nextDriver mobsterList) }
