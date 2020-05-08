module Test.Main where

import Prelude (pure, unit, Unit)
import PSCI.Support (eval)
import Effect (Effect)
import Effect.Console (logShow)

egEvalShow :: Effect Unit
egEvalShow = eval 42

egEvalEff :: Effect Unit
egEvalEff = eval (logShow 42)

main :: Effect Unit
main = pure unit

