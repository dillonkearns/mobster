module Msg exposing (Msg(..))

import Github
import GithubGraphql
import GraphQL.Client.Http
import Os exposing (Os)
import RemoteData exposing (WebData)
import Window


type Msg
    = WindowResized Window.Size
    | GotGithubInfo (WebData Github.Info)
    | TrackDownloadClick Os
    | GraphqlQuery (Result GraphQL.Client.Http.Error GithubGraphql.StarGazerCount)
