module Mobster.Rpg exposing (..)


type alias Experience =
    List Goal


type alias Goal =
    { complete : Bool, description : String }


type alias RpgData =
    { driver : Experience
    , navigator : Experience
    }


init : RpgData
init =
    { driver =
        experienceThings
            [ "Ask a clarifying question about what to type"
            , "Type something you disagree with"
            , "Use a new keyboard shortcut"
            , "Learn something new about tooling"
            , "Ignore a direct instruction from someone who isn't the Navigator"
            ]
    , navigator =
        experienceThings
            [ "Ask for ideas"
            , "Filter the mob's ideas then tell the Driver exactly what to type"
            , "Tell the Driver only your high-level intent and have them implement the details"
            , "Create a failing test. Make it pass. Refactor."
            ]
    }


experienceThings : List String -> Experience
experienceThings stringList =
    List.map initGoal stringList


initGoal : String -> Goal
initGoal description =
    { complete = False, description = description }
