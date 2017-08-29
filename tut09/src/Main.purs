module Main where

import Prelude

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log, logShow)
import Data.Array (filter)
import Data.Either (Either(..))
import Data.Foldable (all, find, foldMapDefaultR, foldr)
import Data.Maybe (Maybe(..))
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
import Partial.Unsafe (unsafePartial)

type Stats = { page :: String
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

both :: String -> Boolean
both s = unwrap $ foldr (<>) mempty $ Conj <$> ([longWord, hasVowels] <*> [s])


main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  log "A curated collection of Monoids and their uses"
  log "\n PS Additive =~ JS Sum"
  logShow $ mempty :: Additive Int -- (Additive 0)
  logShow $ foldMapDefaultR Additive [1, 2, 3]
  log "\n PS Multiplicative =~ JS Product"
  logShow $ mempty :: Multiplicative Int -- (Multiplicative 1)
  logShow $ foldMapDefaultR Multiplicative [1, 2, 3]
  log "\n PS Disj =~ JS Any"
  logShow $ mempty :: Disj Boolean -- (Disj false)
  logShow $ foldMapDefaultR Disj [false, false, true]
  log "\n PS Conj =~ JS All"
  logShow $ mempty :: Conj Boolean -- (Conj true)
  logShow $ foldr (<>) mempty $ Conj <$> [true, true, true]
  log "\n PS Max =~ JS Max"
  logShow $ mempty :: Max Int -- (Max -2147483648)
  logShow $ foldr (<>) mempty $ Max <$> [1, 2, 3]
  log "\n PS Min =~ JS Min"
  logShow $ mempty :: Min Int -- (Min 2147483647)
  logShow $ foldr (<>) mempty $ Min <$> [1, 2, 3]
  log "\n PS Either =~ JS Either"
  logShow $ foldr (<>) mempty $ (\x -> (Additive $ checkViews x.views)) <$> stats
  log "\n PS find uses Maybe instead of Either"
  logShow $ find (\x -> x > 4) [3, 4, 5, 6, 7]
  log "\n PS hasVowels && longWord"
  logShow $ filter both ["gym", "bird", "lilac"]
