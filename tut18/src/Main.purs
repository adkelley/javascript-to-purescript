module Main where

import Prelude

import Control.Apply (lift2)
import Data.Box (Box)
import Effect (Effect)
import Effect.Console (log, logShow)

infixr 4 eq as ≡
infixr 9 compose as ⋘

-- | Use `pure` to wrap a function of zero arguements
addOne ∷ Box (Int → Int)
addOne =
  pure $ \x → x + 1

-- | Canonical example of `apply`
result1 :: Box Int
result1 = addOne `apply` (pure 2)

-- | Use the infix operator for `apply`
-- | The compiler will infer that (pure add)
-- | means (Box add)
result2 :: Box Int
result2 = (pure add) <*> (pure 2) <*> (pure 3)

-- | Use the `lift2` helper method to lift
-- | `add` into the Box applicative constructor,
-- | achieving a shorter form of `result2`
result3 :: Box Int
result3 = lift2 add (pure 2) (pure 4)

-- | Combine the `map` and `apply` methods to
-- | achieve the same result as consequtive `apply`
-- | methods (see result1)
result4 ∷ Box Int
result4 = add <$> (pure 2) <*> (pure 4)

-- | Applicatives are monoidal functors
listResults ∷ Array Int
listResults =
  [\x → x + 1, \y → y * 2] <*> [1, 2]

-- | Laws
identityLaw ∷ Boolean
identityLaw =
  ((pure identity) <*> (pure 1)) ≡ ((pure 1) ∷ Box Int)

homomorphism ∷ Boolean
homomorphism =
  let
    f = \x → x + 1
    y = 1
  in
    ((pure f) <*> (pure y)) ≡ ((pure $ f y) ∷ Box Int)

interchange ∷ Boolean
interchange =
  let
    u = pure $ \x → x + 1
    y = 1
  in
   (u <*> (pure y)) ≡ (((pure (_ $ y)) <*> u) ∷ Box Int)


composition ∷ Boolean
composition =
  let
    u = pure identity
    v = pure $ \x → x + 1
    w = pure 2
  in
    ((pure (⋘)) <*> u <*> v <*> w ) ≡ ((u <*> (v <*> w)) ∷ Box Int)


main :: Effect Unit
main = do
  log "Applicative Functors for multiple arguments"
  logShow result1
  logShow result2
  logShow result3
  logShow result4
  log $ "Applicatives are monoidal functors: " <> show listResults
  log "Applicative functor laws"
  log $ "Identity: " <> (show identityLaw)
  log $ "Homomorphism: " <> (show identityLaw)
  log $ "Interchange: " <> (show interchange)
  log $ "Composition: " <> (show composition)
