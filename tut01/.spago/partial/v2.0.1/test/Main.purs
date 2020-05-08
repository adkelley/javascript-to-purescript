module Test.Main where

import Partial (crashWith)
import Partial.Unsafe (unsafePartial, unsafePartialBecause)

f :: Partial => Int -> Int
f 0 = 0
f _ = crashWith "f: partial function"

safely :: Int
safely = unsafePartial (f 0)

safely2 :: Int
safely2 = unsafePartialBecause "calling f with argument 0 is guaranteed to be safe" (f 0)

main :: forall a. a -> {}
main _ = {}
