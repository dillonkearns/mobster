module RpgPresenterTests exposing (all)

import Test exposing (..)
import Expect
import Mobster.RpgPresenter as RpgPresenter
import Mobster.Data as MobsterData exposing (empty)


all : Test
all =
    describe "rpg presenter"
        [ test "empty mobster data" <|
            \() ->
                empty
                    |> RpgPresenter.present
                    |> Expect.equal []
        ]
