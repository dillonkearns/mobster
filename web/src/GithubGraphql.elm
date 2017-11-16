module GithubGraphql exposing (..)

import GraphQL.Request.Builder exposing (..)
import GraphQL.Request.Builder.Arg as Arg
import Releases


type alias Info =
    { starCount : Int
    , releases : Releases.PlatformUrls
    }


type alias Release =
    { name : String
    , downloadUrl : String
    }


type StarGazerCount
    = StarGazerCount Int


query : Request Query StarGazerCount
query =
    extract
        (field "repository"
            [ "owner" => Arg.string "dillonkearns"
            , "name" => Arg.string "mobster"
            ]
            (extract
                (field "stargazers"
                    []
                    (object StarGazerCount |> with (field "totalCount" [] int))
                )
            )
        )
        |> queryDocument
        |> request ()


(=>) : a -> b -> ( a, b )
(=>) =
    (,)
