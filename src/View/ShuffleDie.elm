module View.ShuffleDie exposing (view)

import Animation
import Element exposing (Device, el)
import Element.Attributes as Attr
import Element.Events
import Setup.Msg as Msg exposing (Msg)
import Styles exposing (StyleElement)


view :
    { model
        | dieStyle : Animation.State
        , device : Device
    }
    -> StyleElement
view ({ device } as model) =
    let
        dimension =
            Styles.responsiveForWidth device ( 40, 100 ) |> Attr.px
    in
    Element.el Styles.ShuffleDieContainer
        [ Attr.width dimension
        , Attr.height dimension
        , Element.Events.onClick Msg.ShuffleMobsters
        ]
    <|
        -- The extra container is needed to center, setting it directly
        -- on the image conflicts with the style animation css
        Element.el Styles.None
            [ Attr.verticalCenter
            , Attr.center
            ]
            (shuffleDie model)


shuffleDie :
    { model
        | dieStyle : Animation.State
        , device : Device
    }
    -> StyleElement
shuffleDie { dieStyle, device } =
    let
        dimension =
            Styles.responsiveForWidth device ( 20, 50 ) |> Attr.px
    in
    Element.image
        Styles.ShuffleDie
        (List.map (\attr -> Attr.toAttr attr) (Animation.render dieStyle)
            ++ [ Attr.height dimension
               , Attr.width dimension
               ]
        )
        { src = "./assets/dice.png", caption = "Shuffle die" }
