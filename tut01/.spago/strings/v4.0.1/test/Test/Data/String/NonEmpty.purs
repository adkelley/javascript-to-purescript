module Test.Data.String.NonEmpty (testNonEmptyString) where

import Prelude

import Data.Array.NonEmpty as NEA
import Data.Maybe (Maybe(..), fromJust)
import Data.String.NonEmpty (Pattern(..), nes)
import Data.String.NonEmpty as NES
import Data.Symbol (SProxy(..))
import Effect (Effect)
import Effect.Console (log)
import Partial.Unsafe (unsafePartial)
import Test.Assert (assert, assertEqual)

testNonEmptyString :: Effect Unit
testNonEmptyString = do

  log "fromString"
  assertEqual
    { actual: NES.fromString ""
    , expected: Nothing
    }
  assertEqual
    { actual: NES.fromString "hello"
    , expected: Just (nes (SProxy :: SProxy "hello"))
    }

  log "toString"
  assertEqual
    { actual: (NES.toString <$> NES.fromString "hello")
    , expected: Just "hello"
    }

  log "appendString"
  assertEqual
    { actual: NES.appendString (nes (SProxy :: SProxy "Hello")) " world"
    , expected: nes (SProxy :: SProxy "Hello world")
    }
  assertEqual
    { actual: NES.appendString (nes (SProxy :: SProxy "Hello")) ""
    , expected: nes (SProxy :: SProxy "Hello")
    }

  log "prependString"
  assertEqual
    { actual: NES.prependString "be" (nes (SProxy :: SProxy "fore"))
    , expected: nes (SProxy :: SProxy "before")
    }
  assertEqual
    { actual: NES.prependString "" (nes (SProxy :: SProxy "fore"))
    , expected: nes (SProxy :: SProxy "fore")
    }

  log "contains"
  assert $ NES.contains (Pattern "") (nes (SProxy :: SProxy "abcd"))
  assert $ NES.contains (Pattern "bc") (nes (SProxy :: SProxy "abcd"))
  assert $ not NES.contains (Pattern "cb") (nes (SProxy :: SProxy "abcd"))
  assert $ NES.contains (Pattern "needle") (nes (SProxy :: SProxy "haystack with needle"))
  assert $ not NES.contains (Pattern "needle") (nes (SProxy :: SProxy "haystack"))

  log "localeCompare"
  assertEqual
    { actual: NES.localeCompare (nes (SProxy :: SProxy "a")) (nes (SProxy :: SProxy "a"))
    , expected: EQ
    }
  assertEqual
    { actual: NES.localeCompare (nes (SProxy :: SProxy "a")) (nes (SProxy :: SProxy "b"))
    , expected: LT
    }
  assertEqual
    { actual: NES.localeCompare (nes (SProxy :: SProxy "b")) (nes (SProxy :: SProxy "a"))
    , expected: GT
    }

  log "replace"
  assertEqual
    { actual: NES.replace (Pattern "b") (NES.NonEmptyReplacement (nes (SProxy :: SProxy "!"))) (nes (SProxy :: SProxy "abc"))
    , expected: nes (SProxy :: SProxy "a!c")
    }
  assertEqual
    { actual: NES.replace (Pattern "b") (NES.NonEmptyReplacement (nes (SProxy :: SProxy "!"))) (nes (SProxy :: SProxy "abbc"))
    , expected: nes (SProxy :: SProxy "a!bc")
    }
  assertEqual
    { actual: NES.replace (Pattern "d") (NES.NonEmptyReplacement (nes (SProxy :: SProxy "!"))) (nes (SProxy :: SProxy "abc"))
    , expected: nes (SProxy :: SProxy "abc")
    }

  log "replaceAll"
  assertEqual
    { actual: NES.replaceAll (Pattern "[b]") (NES.NonEmptyReplacement (nes (SProxy :: SProxy "!"))) (nes (SProxy :: SProxy "a[b]c"))
    , expected: nes (SProxy :: SProxy "a!c")
    }
  assertEqual
    { actual: NES.replaceAll (Pattern "[b]") (NES.NonEmptyReplacement (nes (SProxy :: SProxy "!"))) (nes (SProxy :: SProxy "a[b]c[b]"))
    , expected: nes (SProxy :: SProxy "a!c!")
    }
  assertEqual
    { actual: NES.replaceAll (Pattern "x") (NES.NonEmptyReplacement (nes (SProxy :: SProxy "!"))) (nes (SProxy :: SProxy "abc"))
    , expected: nes (SProxy :: SProxy "abc")
    }

  log "stripPrefix"
  assertEqual
    { actual: NES.stripPrefix (Pattern "") (nes (SProxy :: SProxy "abc"))
    , expected: Just (nes (SProxy :: SProxy "abc"))
    }
  assertEqual
    { actual: NES.stripPrefix (Pattern "a") (nes (SProxy :: SProxy "abc"))
    , expected: Just (nes (SProxy :: SProxy "bc"))
    }
  assertEqual
    { actual: NES.stripPrefix (Pattern "abc") (nes (SProxy :: SProxy "abc"))
    , expected: Nothing
    }
  assertEqual
    { actual: NES.stripPrefix (Pattern "!") (nes (SProxy :: SProxy "abc"))
    , expected: Nothing
    }
  assertEqual
    { actual: NES.stripPrefix (Pattern "http:") (nes (SProxy :: SProxy "http://purescript.org"))
    , expected: Just (nes (SProxy :: SProxy "//purescript.org"))
    }
  assertEqual
    { actual: NES.stripPrefix (Pattern "http:") (nes (SProxy :: SProxy "https://purescript.org"))
    , expected: Nothing
    }
  assertEqual
    { actual: NES.stripPrefix (Pattern "Hello!") (nes (SProxy :: SProxy "Hello!"))
    , expected: Nothing
    }

  log "stripSuffix"
  assertEqual
    { actual: NES.stripSuffix (Pattern ".exe") (nes (SProxy :: SProxy "purs.exe"))
    , expected: Just (nes (SProxy :: SProxy "purs"))
    }
  assertEqual
    { actual: NES.stripSuffix (Pattern ".exe") (nes (SProxy :: SProxy "purs"))
    , expected: Nothing
    }
  assertEqual
    { actual: NES.stripSuffix (Pattern "Hello!") (nes (SProxy :: SProxy "Hello!"))
    , expected: Nothing
    }

  log "toLower"
  assertEqual
    { actual: NES.toLower (nes (SProxy :: SProxy "bAtMaN"))
    , expected: nes (SProxy :: SProxy "batman")
    }

  log "toUpper"
  assertEqual
    { actual: NES.toUpper (nes (SProxy :: SProxy "bAtMaN"))
    , expected: nes (SProxy :: SProxy "BATMAN")
    }

  log "trim"
  assertEqual
    { actual: NES.trim (nes (SProxy :: SProxy "  abc  "))
    , expected: Just (nes (SProxy :: SProxy "abc"))
    }
  assertEqual
    { actual: NES.trim (nes (SProxy :: SProxy "   \n"))
    , expected: Nothing
    }

  log "joinWith"
  assertEqual
    { actual: NES.joinWith "" []
    , expected: ""
    }
  assertEqual
    { actual: NES.joinWith "" [nes (SProxy :: SProxy "a"), nes (SProxy :: SProxy "b")]
    , expected: "ab"
    }
  assertEqual
    { actual: NES.joinWith "--" [nes (SProxy :: SProxy "a"), nes (SProxy :: SProxy "b"), nes (SProxy :: SProxy "c")]
    , expected: "a--b--c"
    }

  log "join1With"
  assertEqual
    { actual: NES.join1With "" (nea [nes (SProxy :: SProxy "a"), nes (SProxy :: SProxy "b")])
    , expected: nes (SProxy :: SProxy "ab")
    }
  assertEqual
    { actual: NES.join1With "--" (nea [nes (SProxy :: SProxy "a"), nes (SProxy :: SProxy "b"), nes (SProxy :: SProxy "c")])
    , expected: nes (SProxy :: SProxy "a--b--c")
    }
  assertEqual
    { actual: NES.join1With ", " (nea [nes (SProxy :: SProxy "apple"), nes (SProxy :: SProxy "banana")])
    , expected: nes (SProxy :: SProxy "apple, banana")
    }
  assertEqual
    { actual: NES.join1With "" (nea [nes (SProxy :: SProxy "apple"), nes (SProxy :: SProxy "banana")])
    , expected: nes (SProxy :: SProxy "applebanana")
    }

  log "joinWith1"
  assertEqual
    { actual: NES.joinWith1 (nes (SProxy :: SProxy " ")) (nea ["a", "b"])
    , expected: nes (SProxy :: SProxy "a b")
    }
  assertEqual
    { actual: NES.joinWith1 (nes (SProxy :: SProxy "--")) (nea ["a", "b", "c"])
    , expected: nes (SProxy :: SProxy "a--b--c")
    }
  assertEqual
    { actual: NES.joinWith1 (nes (SProxy :: SProxy ", ")) (nea ["apple", "banana"])
    , expected: nes (SProxy :: SProxy "apple, banana")
    }
  assertEqual
    { actual: NES.joinWith1 (nes (SProxy :: SProxy "/")) (nea ["a", "b", "", "c", ""])
    , expected: nes (SProxy :: SProxy "a/b//c/")
    }

nea :: Array ~> NEA.NonEmptyArray
nea = unsafePartial fromJust <<< NEA.fromArray
