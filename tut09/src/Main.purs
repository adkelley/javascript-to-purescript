module Main where

import Prelude

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log, logShow)
import Data.Array (filter)
import Data.Either (Either(..))
import Data.Filterable (maybeBool)
import Data.Foldable (class Foldable, foldMap)
import Data.Maybe (Maybe(..))
import Data.Maybe.First (First(..))
import Data.Monoid (class Monoid, mempty)
import Data.Monoid.Additive (Additive(..))
import Data.Monoid.Conj (Conj(..))
import Data.Monoid.Disj (Disj(..))
import Data.Monoid.Multiplicative (Multiplicative(..))
import Data.Newtype (unwrap)
import Data.Ord.Max (Max(..))
import Data.Ord.Min (Min(..))
import Data.String (length)
import Data.String.Regex (Regex, match, regex)
import Data.String.Regex.Flags (RegexFlags(..), RegexFlagsRec)
import Data.Tuple (Tuple(..), fst, snd)
import Partial.Unsafe (unsafePartial)

type Stats =
  { page :: String
  , views :: Maybe Int
  }

goodStats :: Array Stats
goodStats = [ { page: "Home",  views: (Just 1) }
        , { page: "Blog",  views: (Just 4) }
        , { page: "About", views: (Just 10) }
        ]

badStats :: Array Stats
badStats = [ { page: "Home",  views: (Just 1) }
        , { page: "Blog",  views: Nothing  }
        , { page: "About", views: (Just 10)}
        ]

fromNothing :: forall a. Maybe a -> Either String a
fromNothing (Just x) = Right x
fromNothing _ = Left "Nothing"

regexFlags :: RegexFlagsRec
regexFlags = { global: true, ignoreCase: true
             , multiline: false, sticky: false
             , unicode: false
             }

vowelsRegex :: Regex
vowelsRegex =
  unsafePartial
    case regex "[aeiou]" (RegexFlags regexFlags) of
      Right r -> r

hasVowels :: String -> Boolean
hasVowels s =
  case match vowelsRegex s of
    Just _ -> true
    _      -> false

longWord :: String -> Boolean
longWord s = length s > 4


multiple ∷ ∀ m a b c. Foldable c ⇒ Monoid m ⇒ (a -> m)
     -> c (b -> a)
     -> b
     -> m
multiple m = foldMap (compose m)

-- mimics find in Data.Foldable
find :: ∀ c a. Foldable c => (a -> Boolean) -> c a -> Maybe a
find f = unwrap <<< foldMap (First <<< maybeBool f)

toSumAll :: Tuple Int Boolean -> Tuple (Additive Int) (Conj Boolean)
toSumAll (Tuple a b) = Tuple (Additive a) (Conj b)

fromSumAll :: Tuple (Additive Int) (Conj Boolean) -> Tuple Int Boolean
fromSumAll (Tuple (Additive a) (Conj b)) = Tuple a b


main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  log "A curated collection of monoids and their uses"
  log "\nPS Additive =~ JS Sum"
  logShow $ mempty :: Additive Int -- (Additive 0)
  logShow $ foldMap Additive [1, 2, 3]
  log "\nPS Multiplicative =~ JS Product"
  logShow $ mempty :: Multiplicative Int -- (Multiplicative 1)
  logShow $ foldMap Multiplicative [1, 2, 3]
  log "\nPS Disj =~ JS Any"
  logShow $ mempty :: Disj Boolean -- (Disj false)
  logShow $ foldMap Disj [false, false, true]
  log "\nPS Conj =~ JS All"
  logShow $ mempty :: Conj Boolean -- (Conj true)
  logShow $ foldMap Conj [true, true, true]
  log "\nPS First =~ JS First"
  logShow $ mempty :: First Int -- Nothing
  logShow $ foldMap First [Nothing, Just 1, Nothing] -- First ((Just 1))
  log "\nPS Max =~ JS Max"
  logShow $ mempty :: Max Int -- (Max -2147483648)
  logShow $ foldMap Max [1, 2, 3] -- (Max 3)
  log "\nPS Min =~ JS Min"
  logShow $ mempty :: Min Int -- (Min 2147483647)
  logShow $ foldMap Min [1, 2, 3]  -- (Min 1)
  log "\nCount # of page views"
  logShow $ foldMap (Additive <<< fromNothing <<< _.views) goodStats
  logShow $ foldMap (Additive <<< fromNothing <<< _.views) badStats
  log "\nThis find uses Maybe instead of Either"
  logShow $ find (_ > 4) [3, 4, 5, 6, 7]
  log "\nPS hasVowels && longWord"
  logShow $ filter (unwrap <<< multiple Conj [hasVowels, longWord]) ["gym", "bird", "lilac"]
  logShow $ filter (unwrap <<< multiple Disj [hasVowels, longWord]) ["gym", "bird", "lilac"]
  logShow $ filter (unwrap <<< multiple Conj [(_ < 4), (_ > 1)]) [0, 1, 2, 3, 4]
  log "\nPS Tuple =~ JS Pair"
  logShow $ foldMap Additive [(Tuple 1 2), (Tuple 3 4)]
  logShow $ foldMap Conj [(Tuple true false), (Tuple true false)]
  logShow $ fromSumAll $ foldMap toSumAll [(Tuple 1 false), (Tuple 2 false)]
