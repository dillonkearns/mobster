module Views.Fa exposing (fa)

import Element exposing (..)
import Element.Attributes exposing (..)
import Styles exposing (..)


fa : Styles -> String -> StyleElement
fa style faClass =
    Element.el style [ class <| "fa " ++ faClass ] Element.empty
