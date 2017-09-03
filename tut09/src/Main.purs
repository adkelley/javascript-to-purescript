module Main where

import Prelude

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log, logShow)
import Data.Array (filter)
import Data.Either (Either(..))
import Data.Foldable (and, find, foldMap, sum)
import Data.Maybe (Maybe(..))
import Data.Maybe.First (First(..))
import Data.Monoid (mempty)
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
import Data.Tuple (Tuple(..))
import Partial.Unsafe (unsafePartial)

type Stats =
  { page :: String
  , views :: Maybe Int
  }

stats :: Array Stats
stats = [ { page: "Home",  views: (Just 1) }
        , { page: "About", views: (Just 10)}
        , { page: "Blog",  views: Nothing  }
        ]

checkViews :: Maybe Int -> Either String Int
checkViews Nothing = Left "error: views is null"
checkViews (Just x) = Right x

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


-- longWord and hasVowels are both predicates so that means
-- you can use && or || via the heyting algebra
both :: Conj String -> Conj Boolean
both = map (longWord && hasVowels)


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
  log "\nPS Either =~ JS Either"
  logShow $ foldMap (\x -> Additive $ checkViews x.views) stats
  log "\nPS find uses Maybe instead of Either"
  logShow $ find (_ > 4) [3, 4, 5, 6, 7]
  log "\nPS hasVowels && longWord"
  logShow $ filter (unwrap <<< both) $ Conj <$> ["gym", "bird", "lilac"]
  log "\nPS Tuple =~ JS Pair"
  logShow $ sum [(Tuple 1 2), (Tuple 3 4)]
  logShow $ and [(Tuple true false), (Tuple true false)]
