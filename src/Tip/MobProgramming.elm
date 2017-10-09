module Tip.MobProgramming exposing (tips)

import Tip exposing (Tip)


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
      , title = "Mob Decision-Making"
      , body =
            "Arguing about solutions? Try going with the least experienced navigator and have the more experienced team members course correct only as needed."
      , author = "The Hunter Mob"
      }
    , { url = "https://www.infoq.com/news/2016/06/mob-programming-zuill"
      , title = "Lean Thinking"
      , body =
            "The goal is not to be productive but effective. To draw a line with Lean Practices, being productive and not effective is usually a good way to produce waste quickly."
      , author = "Woody Zuill"
      }
    , { url = "https://www.infoq.com/news/2016/06/mob-programming-zuill"
      , title = "Mob Programming"
      , body =
            "It's not about Mob Programming. It’s about discovering the principles and practices that are important in the context of the work you are doing, and the people you are working with."
      , author = "Woody Zuill"
      }
    , { url = "https://agilein3minut.es/32"
      , title = "Shared Attention"
      , body =
            "With everyone paying attention pretty often, we stay focused, never stay stuck for long, and make better choices."
      , author = "Amitai Schleier"
      }
    , { url = "https://agilein3minut.es/32"
      , title = "Limit WIP"
      , body =
            """Since there's no "my bugfix" or "your feature", we naturally limit our Work In Progress."""
      , author = "Amitai Schleier"
      }
    ]
