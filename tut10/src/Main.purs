module Main where

import Prelude

import Effect (Effect)
import Effect.Console (log, logShow)
import Data.Foldable (class Foldable, foldMap)
import Data.Group (ginverse)
import Data.List (List(..), foldr, (:))
import Data.Maybe (Maybe(..))
import Data.Maybe.Last (Last(..))
import Data.Monoid.Additive (Additive(..))
import Data.Monoid.Dual (Dual(..))
import Data.Monoid.Endo (Endo(..))
import Data.Newtype (unwrap)
import Data.Tuple (Tuple(..), fst, snd)

-- Take a foldable structure of monoids and
-- switch them using the Dual of the monoid
switchArgs :: ∀ f m. Foldable f ⇒ Monoid m ⇒ f m → Dual m
switchArgs = foldMap Dual


main :: Effect Unit
main = do
  log "Unbox types with foldMap"
  log "\nIdentity: id <<< p = p <<< id = p"
  logShow $ foldMap identity [(Additive 1), (Additive 2), (Additive 3)]
  logShow $ foldMap Additive [1, 2, 3]

  log "\nWorking with Tuples of different types, then use 'fst' or 'snd'"
  logShow $ foldMap (Additive <<< snd) [Tuple "brian" 1, Tuple "sarah" 2] -- (Additive 3)
  logShow $ foldMap (Dual <<< fst) [Tuple "Brian" 1, Tuple " and " 2, Tuple "Sarah" 3] -- (Dual "Sarah and Brian")

  log "\nA Group is a monoid of inverses"
  logShow $ (Additive 3) <> ginverse (Additive 3)

  log "\nDual monoid"
  logShow $ switchArgs ["Alex", ", ", "Kelley"] -- (Dual "Kelley, Alex")
  logShow $ switchArgs ("Alex" : ", " : "Kelley" : Nil) : Nil -- (Dual ("Kelley" : ", " : "Alex" : Nil))

  log "\nArrays are monoids:"
  logShow $ foldMap identity [ ["Foo"], [", "], ["Bar"] ]

  log "\nLists are monoids too:"
  logShow $ foldMap identity ("Foo" : ", " : "Bar" : Nil) : Nil

  log "\nEndomorphisms: (a -> a) composition is associative and therefore a monoid"
  let f = ((+) 1) <<< (((*) 2) <<< negate)
  let g = ((+) 1 <<< ((*) 2)) <<< negate
  let h = unwrap $ foldMap Endo [(+) 1, (*) 2, negate]
  log $ "f: " <> (show $ f 5) <> " " <>
        "g: " <> (show $ g 5) <> " " <>
        "h: " <> (show $ h 5)
  let i = unwrap $ foldMap Endo [(+) 1, (*) 2, negate]
  logShow $ i 5 -- -9

  log "\nThis is your Last monoid"
  logShow (mempty :: (Last Int))
  logShow $ foldMap Last [(Just 1), Nothing, (Just 2)] -- (Just 2)

  log "\nfoldMap for monoids is foldr, mempty and map combined"
  let ms = map Additive (1 : 2 : 3 : Nil)
  let fs = foldr (<>) mempty
  logShow $ fs ms == foldMap Additive (1 : 2 : 3 : Nil) -- true
