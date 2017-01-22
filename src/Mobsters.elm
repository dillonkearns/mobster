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
            Array.get 0 mobstersAsArray

        driver =
            case maybeDriver of
                Just justDriver ->
                    justDriver

                Nothing ->
                    ""

        maybeNavigator =
            Array.get 1 mobstersAsArray

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
