module Tip exposing (..)

import Random
import Array
import Html exposing (..)


type alias Tip =
    { url : String
    , body : String
    , title : String
    , author : String
    }


get : Int -> Tip
get index =
    let
        maybeTip =
            Array.get index (Array.fromList tips)
    in
        Maybe.withDefault emptyTip maybeTip


random : Random.Generator Int
random =
    (Random.int 0 ((List.length tips) - 1))


emptyTip : Tip
emptyTip =
    { url = "", title = "", body = "", author = "" }


tips : List Tip
tips =
    [ { url = "http://llewellynfalco.blogspot.com/2014/06/llewellyns-strong-style-pairing.html"
      , title = "Driver/Navigator Pattern"
      , body = "For an idea to go from your head into the computer it MUST go through someone else's hands"
      , author = "Llewellyn Falco"
      }
    , { url = "http://llewellynfalco.blogspot.com/2014/06/llewellyns-strong-style-pairing.html"
      , title = "Trust your navigator"
      , body =
            "The right time to discuss and challenge design decisions is after the solution is out of the navigator's head."
      , author = "Llewellyn Falco"
      }
    , { url = "http://llewellynfalco.blogspot.com/2014/06/llewellyns-strong-style-pairing.html"
      , title = "Driving With An Idea"
      , body = "What if I have an idea I want to implement? Great! Switch places and become the navigator."
      , author = "Llewellyn Falco"
      }
    , { url = "https://github.com/MobProgramming/MobTimer.Python/blob/master/Tips/MobProgramming"
      , title = "Mob Decision-Making Protocol"
      , body =
            "Arguing about solutions? Try going with the least experienced navigator and have the more experienced team members course correct only as needed."
      , author = "The Hunter Mob"
      }
    ]


tipView : Tip -> Html msg
tipView tip =
    blockquote []
        [ p [] [ text tip.body ]
        , small [] [ text tip.author ]
        ]
