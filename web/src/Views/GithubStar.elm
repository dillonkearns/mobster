module Views.GithubStar exposing (view)

import Element
import Styles exposing (StyleElement)
import Svg exposing (path, style, svg)
import Svg.Attributes exposing (d, fillRule, height, viewBox, width)


-- source: https://octicons.github.com


view : StyleElement
view =
    svg [ width "20px", height "20px", viewBox "0 0 14 14" ]
        [ path
            [ fillRule "evenodd"
            , viewBox "0 0 100 100"
            , d "M14 6l-4.9-.64L7 1 4.9 5.36 0 6l3.6 3.26L2.67 14 7 11.67 11.33 14l-.93-4.74z"
            ]
            []
        ]
        |> Element.html
