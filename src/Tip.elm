module Tip exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Random
import Array


type alias Tip msg =
    { url : String
    , body : Html msg
    , title : String
    }


get : Int -> Tip msg
get index =
    let
        maybeTip =
            Array.get index (Array.fromList tips)
    in
        Maybe.withDefault emptyTip maybeTip


random : Random.Generator Int
random =
    (Random.int 0 ((List.length tips) - 1))


emptyTip : Tip msg
emptyTip =
    { url = "", title = "", body = text "" }


tips : List (Tip msg)
tips =
    [ { url = "http://llewellynfalco.blogspot.com/2014/06/llewellyns-strong-style-pairing.html"
      , body =
            blockquote []
                [ p [] [ text "For an idea to go from your head into the computer it MUST go through someone else's hands" ]
                , small [] [ text "Llewellyn Falco" ]
                ]
      , title = "Driver/Navigator Pattern"
      }
    , { url = "http://llewellynfalco.blogspot.com/2014/06/llewellyns-strong-style-pairing.html"
      , body =
            blockquote []
                [ p [ style [ ( "font-size", "20px" ) ] ] [ text "When you are the driver trust that your navigator knows what they are telling you. If you don't understand what they are telling you ask questions, but if you don't understand why they are telling you something don't worry about it until you've finished the method or section of code. The right time to discuss and challenge design decisions is after the solution is out of the navigator's head or when the navigator is confused and unable to navigate." ]
                , small [] [ text "Llewellyn Falco" ]
                ]
      , title =
            "Trust your navigator"
      }
    , { url = "http://llewellynfalco.blogspot.com/2014/06/llewellyns-strong-style-pairing.html"
      , title =
            "Driving With An Idea"
      , body =
            blockquote []
                [ p [] [ text "What if I have an idea I want to implement? Great! Switch places and become the navigator." ]
                , small [] [ text "Llewellyn Falco" ]
                ]
      }
    ]
