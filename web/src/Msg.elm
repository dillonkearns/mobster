module Msg exposing (Msg(..))

import Github
import Os exposing (Os)
import RemoteData exposing (WebData)
import Window


type Msg
    = WindowResized Window.Size
    | GotGithubInfo (WebData Github.Info)
    | TrackDownloadClick Os
