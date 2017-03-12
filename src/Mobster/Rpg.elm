module Mobster.Rpg exposing (..)

import EveryDict exposing (EveryDict)


type Level1Role
    = Driver
    | Navigator


type Role
    = L1Role Level1Role


type alias Experience =
    List Goal


type alias Goal =
    { complete : Bool, description : String }


type alias RpgData =
    EveryDict Role Experience


init : RpgData
init =
    EveryDict.fromList
        [ ( (L1Role Driver)
          , experienceThings
                [ "Ask a clarifying question about what to type"
                , "Type something you disagree with"
                , "Use a new keyboard shortcut"
                , "Learn something new about tooling"
                , "Ignore a direct instruction from someone who isn't the Navigator"
                ]
          )
        ]


getExperience : Role -> RpgData -> Maybe Experience
getExperience role rpgData =
    EveryDict.get role rpgData


experienceThings : List String -> Experience
experienceThings stringList =
    List.map (\description -> { complete = False, description = description }) stringList
