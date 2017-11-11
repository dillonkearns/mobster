module Msg exposing (Msg(..))

import Github
import RemoteData exposing (WebData)
import Window


type Msg
    = WindowResized Window.Size
    | GotGithubInfo (WebData Github.Info)
