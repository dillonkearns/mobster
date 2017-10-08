module Tip.All exposing (tips)

import Tip exposing (Tip)
import Tip.AgileManifesto
import Tip.MobProgramming


tips : List Tip
tips =
    Tip.AgileManifesto.tips
        ++ Tip.MobProgramming.tips
