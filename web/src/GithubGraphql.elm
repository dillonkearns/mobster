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



-- {
--   repository(owner: "dillonkearns", name: "mobster") {
--     releases(last: 1) {
--       totalCount
--       nodes {
--         releaseAssets(last: 30) {
--           edges {
--             node {
--               downloadUrl
--               name
--               downloadCount
--             }
--           }
--         }
--         description
--       }
--     }
--     stargazers {
--       totalCount
--     }
--   }
-- }
-- query : Document Query User { vars | userID : String }


type StarGazerCount
    = StarGazerCount Int


query : Request Query StarGazerCount
query =
    extract
        (field "repository"
            [ "owner" => Arg.string "dillonkearns"
            , "name" => Arg.string "mobster"
            ]
            starCount
        )
        |> queryDocument
        |> request ()


starCount : ValueSpec NonNull ObjectType StarGazerCount ()
starCount =
    extract
        (field "stargazers"
            []
            (object StarGazerCount |> with (field "totalCount" [] int))
        )


(=>) : a -> b -> ( a, b )
(=>) =
    (,)
