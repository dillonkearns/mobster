module Mobsters exposing (..)


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
