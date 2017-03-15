module Mobster.Rpg exposing (Experience, RpgData, Goal, init)


type alias Experience =
    List Goal


type alias Goal =
    { complete : Bool, description : String }


type alias RpgData =
    { driver : Experience
    , navigator : Experience
    , researcher : Experience
    , sponsor : Experience
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
    , researcher =
        experienceThings
            [ "Find and share relevant information from documentation"
            , "Find and share relevant information from a blog"
            , "Find and share relevant information from a coding forum"
            ]
    , sponsor =
        experienceThings
            [ "Amplify the unheard voice"
            , "Pick the mobber with the least privilege (gender/race/class/seniority/etc) and support their contributions"
            , "Celebrate moments of excellence"
            ]
    }


experienceThings : List String -> Experience
experienceThings stringList =
    List.map initGoal stringList


initGoal : String -> Goal
initGoal description =
    { complete = False, description = description }
