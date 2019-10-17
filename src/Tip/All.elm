module Tip.All exposing (tips)

import Tip exposing (Tip)
import Tip.AgileManifesto
import Tip.MobProgramming
import Tip.PragmaticProgrammer


tips : List Tip
tips =
    Tip.AgileManifesto.tips
        ++ Tip.MobProgramming.tips
        ++ Tip.PragmaticProgrammer.tips
