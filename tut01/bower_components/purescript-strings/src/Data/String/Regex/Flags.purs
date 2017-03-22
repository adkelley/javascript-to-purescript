module Data.String.Regex.Flags where

import Prelude

import Control.MonadPlus (guard)

import Data.Monoid (class Monoid)
import Data.String (joinWith)

type RegexFlagsRec =
  { global :: Boolean
  , ignoreCase :: Boolean
  , multiline :: Boolean
  , sticky :: Boolean
  , unicode :: Boolean
  }

-- | Flags that control matching.
data RegexFlags = RegexFlags RegexFlagsRec

-- | All flags set to false.
noFlags :: RegexFlags
noFlags = RegexFlags
  { global: false
  , ignoreCase: false
  , multiline: false
  , sticky: false
  , unicode: false
  }

-- | Only global flag set to true
global :: RegexFlags
global = RegexFlags
  { global: true
  , ignoreCase: false
  , multiline: false
  , sticky: false
  , unicode: false
  }

-- | Only ignoreCase flag set to true
ignoreCase :: RegexFlags
ignoreCase = RegexFlags
  { global: false
  , ignoreCase: true
  , multiline: false
  , sticky: false
  , unicode: false
  }

-- | Only multiline flag set to true
multiline :: RegexFlags
multiline = RegexFlags
  { global: false
  , ignoreCase: false
  , multiline: true
  , sticky: false
  , unicode: false
  }

-- | Only sticky flag set to true
sticky :: RegexFlags
sticky = RegexFlags
  { global: false
  , ignoreCase: false
  , multiline: false
  , sticky: true
  , unicode: false
  }

-- | Only unicode flag set to true
unicode :: RegexFlags
unicode = RegexFlags
  { global: false
  , ignoreCase: false
  , multiline: false
  , sticky: false
  , unicode: true
  }

instance semigroupRegexFlags :: Semigroup RegexFlags where
  append (RegexFlags x) (RegexFlags y) = RegexFlags
    { global: x.global || y.global
    , ignoreCase: x.ignoreCase || y.ignoreCase
    , multiline: x.multiline || y.multiline
    , sticky: x.sticky || y.sticky
    , unicode: x.unicode || y.unicode
    }

instance monoidRegexFlags :: Monoid RegexFlags where
  mempty = noFlags

instance eqRegexFlags :: Eq RegexFlags where
  eq (RegexFlags x) (RegexFlags y)
    = x.global == y.global
    && x.ignoreCase == y.ignoreCase
    && x.multiline == y.multiline
    && x.sticky == y.sticky
    && x.unicode == y.unicode

instance showRegexFlags :: Show RegexFlags where
  show (RegexFlags flags) =
    let
      usedFlags =
        []
        <> (guard flags.global $> "global")
        <> (guard flags.ignoreCase $> "ignoreCase")
        <> (guard flags.multiline $> "multiline")
        <> (guard flags.sticky $> "sticky")
        <> (guard flags.unicode $> "unicode")
    in
      if usedFlags == []
      then "noFlags"
      else "(" <> joinWith " <> " usedFlags <> ")"
