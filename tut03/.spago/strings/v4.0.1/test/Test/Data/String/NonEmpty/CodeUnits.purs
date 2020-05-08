module Test.Data.String.NonEmpty.CodeUnits (testNonEmptyStringCodeUnits) where

import Prelude

import Data.Array.NonEmpty as NEA
import Data.Enum (fromEnum)
import Data.Maybe (Maybe(..), fromJust)
import Data.String.NonEmpty (Pattern(..), nes)
import Data.String.NonEmpty.CodeUnits as NESCU
import Data.Symbol (SProxy(..))
import Effect (Effect)
import Effect.Console (log)
import Partial.Unsafe (unsafePartial)
import Test.Assert (assertEqual)

testNonEmptyStringCodeUnits :: Effect Unit
testNonEmptyStringCodeUnits = do

  log "fromCharArray"
  assertEqual
    { actual: NESCU.fromCharArray []
    , expected: Nothing
    }
  assertEqual
    { actual: NESCU.fromCharArray ['a', 'b']
    , expected: Just (nes (SProxy :: SProxy "ab"))
    }

  log "fromNonEmptyCharArray"
  assertEqual
    { actual: NESCU.fromNonEmptyCharArray (NEA.singleton 'b')
    , expected: NESCU.singleton 'b'
    }

  log "singleton"
  assertEqual
    { actual: NESCU.singleton 'a'
    , expected: nes (SProxy :: SProxy "a")
    }

  log "cons"
  assertEqual
    { actual: NESCU.cons 'a' "bc"
    , expected: nes (SProxy :: SProxy "abc")
    }
  assertEqual
    { actual: NESCU.cons 'a' ""
    , expected: nes (SProxy :: SProxy "a")
    }

  log "snoc"
  assertEqual
    { actual: NESCU.snoc 'c' "ab"
    , expected: nes (SProxy :: SProxy "abc")
    }
  assertEqual
    { actual: NESCU.snoc 'a' ""
    , expected: nes (SProxy :: SProxy "a")
    }

  log "fromFoldable1"
  assertEqual
    { actual: NESCU.fromFoldable1 (nea ['a'])
    , expected: nes (SProxy :: SProxy "a")
    }
  assertEqual
    { actual: NESCU.fromFoldable1 (nea ['a', 'b', 'c'])
    , expected: nes (SProxy :: SProxy "abc")
    }

  log "charAt"
  assertEqual
    { actual: NESCU.charAt 0 (nes (SProxy :: SProxy "a"))
    , expected: Just 'a'
    }
  assertEqual
    { actual: NESCU.charAt 1 (nes (SProxy :: SProxy "a"))
    , expected: Nothing
    }
  assertEqual
    { actual: NESCU.charAt 0 (nes (SProxy :: SProxy "ab"))
    , expected: Just 'a'
    }
  assertEqual
    { actual: NESCU.charAt 1 (nes (SProxy :: SProxy "ab"))
    , expected: Just 'b'
    }
  assertEqual
    { actual: NESCU.charAt 2 (nes (SProxy :: SProxy "ab"))
    , expected: Nothing
    }
  assertEqual
    { actual: NESCU.charAt 2 (nes (SProxy :: SProxy "Hello"))
    , expected: Just 'l'
    }
  assertEqual
    { actual: NESCU.charAt 10 (nes (SProxy :: SProxy "Hello"))
    , expected: Nothing
    }

  log "charCodeAt"
  assertEqual
    { actual: fromEnum <$> NESCU.charAt 0 (nes (SProxy :: SProxy "a"))
    , expected: Just 97
    }
  assertEqual
    { actual: fromEnum <$> NESCU.charAt 1 (nes (SProxy :: SProxy "a"))
    , expected: Nothing
    }
  assertEqual
    { actual: fromEnum <$> NESCU.charAt 0 (nes (SProxy :: SProxy "ab"))
    , expected: Just 97
    }
  assertEqual
    { actual: fromEnum <$> NESCU.charAt 1 (nes (SProxy :: SProxy "ab"))
    , expected: Just 98
    }
  assertEqual
    { actual: fromEnum <$> NESCU.charAt 2 (nes (SProxy :: SProxy "ab"))
    , expected: Nothing
    }
  assertEqual
    { actual: fromEnum <$> NESCU.charAt 2 (nes (SProxy :: SProxy "5 €"))
    , expected: Just 0x20AC
    }
  assertEqual
    { actual: fromEnum <$> NESCU.charAt 10 (nes (SProxy :: SProxy "5 €"))
    , expected: Nothing
    }

  log "toChar"
  assertEqual
    { actual: NESCU.toChar (nes (SProxy :: SProxy "a"))
    , expected: Just 'a'
    }
  assertEqual
    { actual: NESCU.toChar (nes (SProxy :: SProxy "ab"))
    , expected: Nothing
    }

  log "toCharArray"
  assertEqual
    { actual: NESCU.toCharArray (nes (SProxy :: SProxy "a"))
    , expected: ['a']
    }
  assertEqual
    { actual: NESCU.toCharArray (nes (SProxy :: SProxy "ab"))
    , expected: ['a', 'b']
    }
  assertEqual
    { actual: NESCU.toCharArray (nes (SProxy :: SProxy "Hello☺\n"))
    , expected: ['H','e','l','l','o','☺','\n']
    }

  log "toNonEmptyCharArray"
  assertEqual
    { actual: NESCU.toNonEmptyCharArray (nes (SProxy :: SProxy "ab"))
    , expected: nea ['a', 'b']
    }

  log "uncons"
  assertEqual
    { actual: NESCU.uncons (nes (SProxy :: SProxy "a"))
    , expected: { head: 'a', tail: Nothing }
    }
  assertEqual
    { actual: NESCU.uncons (nes (SProxy :: SProxy "Hello World"))
    , expected: { head: 'H', tail: Just (nes (SProxy :: SProxy "ello World")) }
    }

  log "takeWhile"
  assertEqual
    { actual: NESCU.takeWhile (\c -> true) (nes (SProxy :: SProxy "abc"))
    , expected: Just (nes (SProxy :: SProxy "abc"))
    }
  assertEqual
    { actual: NESCU.takeWhile (\c -> false) (nes (SProxy :: SProxy "abc"))
    , expected: Nothing
    }
  assertEqual
    { actual: NESCU.takeWhile (\c -> c /= 'b') (nes (SProxy :: SProxy "aabbcc"))
    , expected: Just (nes (SProxy :: SProxy "aa"))
    }
  assertEqual
    { actual: NESCU.takeWhile (_ /= ':') (nes (SProxy :: SProxy "http://purescript.org"))
    , expected: Just (nes (SProxy :: SProxy "http"))
    }
  assertEqual
    { actual: NESCU.takeWhile (_ == 'a') (nes (SProxy :: SProxy "xyz"))
    , expected: Nothing
    }

  log "dropWhile"
  assertEqual
    { actual: NESCU.dropWhile (\c -> true) (nes (SProxy :: SProxy "abc"))
    , expected: Nothing
    }
  assertEqual
    { actual: NESCU.dropWhile (\c -> false) (nes (SProxy :: SProxy "abc"))
    , expected: Just (nes (SProxy :: SProxy "abc"))
    }
  assertEqual
    { actual: NESCU.dropWhile (\c -> c /= 'b') (nes (SProxy :: SProxy "aabbcc"))
    , expected: Just (nes (SProxy :: SProxy "bbcc"))
    }
  assertEqual
    { actual: NESCU.dropWhile (_ /= '.') (nes (SProxy :: SProxy "Test.purs"))
    , expected: Just (nes (SProxy :: SProxy ".purs"))
    }

  log "indexOf"
  assertEqual
    { actual: NESCU.indexOf (Pattern "") (nes (SProxy :: SProxy "abcd"))
    , expected: Just 0
    }
  assertEqual
    { actual: NESCU.indexOf (Pattern "bc") (nes (SProxy :: SProxy "abcd"))
    , expected: Just 1
    }
  assertEqual
    { actual: NESCU.indexOf (Pattern "cb") (nes (SProxy :: SProxy "abcd"))
    , expected: Nothing
    }

  log "indexOf'"
  assertEqual
    { actual: NESCU.indexOf' (Pattern "") (-1) (nes (SProxy :: SProxy "ab"))
    , expected: Nothing
    }
  assertEqual
    { actual: NESCU.indexOf' (Pattern "") 0 (nes (SProxy :: SProxy "ab"))
    , expected: Just 0
    }
  assertEqual
    { actual: NESCU.indexOf' (Pattern "") 1 (nes (SProxy :: SProxy "ab"))
    , expected: Just 1
    }
  assertEqual
    { actual: NESCU.indexOf' (Pattern "") 2 (nes (SProxy :: SProxy "ab"))
    , expected: Just 2
    }
  assertEqual
    { actual: NESCU.indexOf' (Pattern "") 3 (nes (SProxy :: SProxy "ab"))
    , expected: Nothing
    }
  assertEqual
    { actual: NESCU.indexOf' (Pattern "bc") 0 (nes (SProxy :: SProxy "abcd"))
    , expected: Just 1
    }
  assertEqual
    { actual: NESCU.indexOf' (Pattern "bc") 1 (nes (SProxy :: SProxy "abcd"))
    , expected: Just 1
    }
  assertEqual
    { actual: NESCU.indexOf' (Pattern "bc") 2 (nes (SProxy :: SProxy "abcd"))
    , expected: Nothing
    }
  assertEqual
    { actual: NESCU.indexOf' (Pattern "cb") 0 (nes (SProxy :: SProxy "abcd"))
    , expected: Nothing
    }

  log "lastIndexOf"
  assertEqual
    { actual: NESCU.lastIndexOf (Pattern "") (nes (SProxy :: SProxy "abcd"))
    , expected: Just 4
    }
  assertEqual
    { actual: NESCU.lastIndexOf (Pattern "bc") (nes (SProxy :: SProxy "abcd"))
    , expected: Just 1
    }
  assertEqual
    { actual: NESCU.lastIndexOf (Pattern "cb") (nes (SProxy :: SProxy "abcd"))
    , expected: Nothing
    }

  log "lastIndexOf'"
  assertEqual
    { actual: NESCU.lastIndexOf' (Pattern "") (-1) (nes (SProxy :: SProxy "ab"))
    , expected: Nothing
    }
  assertEqual
    { actual: NESCU.lastIndexOf' (Pattern "") 0 (nes (SProxy :: SProxy "ab"))
    , expected: Just 0
    }
  assertEqual
    { actual: NESCU.lastIndexOf' (Pattern "") 1 (nes (SProxy :: SProxy "ab"))
    , expected: Just 1
    }
  assertEqual
    { actual: NESCU.lastIndexOf' (Pattern "") 2 (nes (SProxy :: SProxy "ab"))
    , expected: Just 2
    }
  assertEqual
    { actual: NESCU.lastIndexOf' (Pattern "") 3 (nes (SProxy :: SProxy "ab"))
    , expected: Nothing
    }
  assertEqual
    { actual: NESCU.lastIndexOf' (Pattern "bc") 0 (nes (SProxy :: SProxy "abcd"))
    , expected: Nothing
    }
  assertEqual
    { actual: NESCU.lastIndexOf' (Pattern "bc") 1 (nes (SProxy :: SProxy "abcd"))
    , expected: Just 1
    }
  assertEqual
    { actual: NESCU.lastIndexOf' (Pattern "bc") 2 (nes (SProxy :: SProxy "abcd"))
    , expected: Just 1
    }
  assertEqual
    { actual: NESCU.lastIndexOf' (Pattern "cb") 0 (nes (SProxy :: SProxy "abcd"))
    , expected: Nothing
    }

  log "length"
  assertEqual
    { actual: NESCU.length (nes (SProxy :: SProxy "a"))
    , expected: 1
    }
  assertEqual
    { actual: NESCU.length (nes (SProxy :: SProxy "ab"))
    , expected: 2
    }

  log "take"
  assertEqual
    { actual: NESCU.take 0 (nes (SProxy :: SProxy "ab"))
    , expected: Nothing
    }
  assertEqual
    { actual: NESCU.take 1 (nes (SProxy :: SProxy "ab"))
    , expected: Just (nes (SProxy :: SProxy "a"))
    }
  assertEqual
    { actual: NESCU.take 2 (nes (SProxy :: SProxy "ab"))
    , expected: Just (nes (SProxy :: SProxy "ab"))
    }
  assertEqual
    { actual: NESCU.take 3 (nes (SProxy :: SProxy "ab"))
    , expected: Just (nes (SProxy :: SProxy "ab"))
    }
  assertEqual
    { actual: NESCU.take (-1) (nes (SProxy :: SProxy "ab"))
    , expected: Nothing
    }

  log "takeRight"
  assertEqual
    { actual: NESCU.takeRight 0 (nes (SProxy :: SProxy "ab"))
    , expected: Nothing
    }
  assertEqual
    { actual: NESCU.takeRight 1 (nes (SProxy :: SProxy "ab"))
    , expected: Just (nes (SProxy :: SProxy "b"))
    }
  assertEqual
    { actual: NESCU.takeRight 2 (nes (SProxy :: SProxy "ab"))
    , expected: Just (nes (SProxy :: SProxy "ab"))
    }
  assertEqual
    { actual: NESCU.takeRight 3 (nes (SProxy :: SProxy "ab"))
    , expected: Just (nes (SProxy :: SProxy "ab"))
    }
  assertEqual
    { actual: NESCU.takeRight (-1) (nes (SProxy :: SProxy "ab"))
    , expected: Nothing
    }

  log "drop"
  assertEqual
    { actual: NESCU.drop 0 (nes (SProxy :: SProxy "ab"))
    , expected: Just (nes (SProxy :: SProxy "ab"))
    }
  assertEqual
    { actual: NESCU.drop 1 (nes (SProxy :: SProxy "ab"))
    , expected: Just (nes (SProxy :: SProxy "b"))
    }
  assertEqual
    { actual: NESCU.drop 2 (nes (SProxy :: SProxy "ab"))
    , expected: Nothing
    }
  assertEqual
    { actual: NESCU.drop 3 (nes (SProxy :: SProxy "ab"))
    , expected: Nothing
    }
  assertEqual
    { actual: NESCU.drop (-1) (nes (SProxy :: SProxy "ab"))
    , expected: Just (nes (SProxy :: SProxy "ab"))
    }

  log "dropRight"
  assertEqual
    { actual: NESCU.dropRight 0 (nes (SProxy :: SProxy "ab"))
    , expected: Just (nes (SProxy :: SProxy "ab"))
    }
  assertEqual
    { actual: NESCU.dropRight 1 (nes (SProxy :: SProxy "ab"))
    , expected: Just (nes (SProxy :: SProxy "a"))
    }
  assertEqual
    { actual: NESCU.dropRight 2 (nes (SProxy :: SProxy "ab"))
    , expected: Nothing
    }
  assertEqual
    { actual: NESCU.dropRight 3 (nes (SProxy :: SProxy "ab"))
    , expected: Nothing
    }
  assertEqual
    { actual: NESCU.dropRight (-1) (nes (SProxy :: SProxy "ab"))
    , expected: Just (nes (SProxy :: SProxy "ab"))
    }

  log "countPrefix"
  assertEqual
    { actual: NESCU.countPrefix (_ == 'a') (nes (SProxy :: SProxy "ab"))
    , expected: 1
    }
  assertEqual
    { actual: NESCU.countPrefix (_ == 'a') (nes (SProxy :: SProxy "aaab"))
    , expected: 3
    }
  assertEqual
    { actual: NESCU.countPrefix (_ == 'a') (nes (SProxy :: SProxy "abaa"))
    , expected: 1
    }
  assertEqual
    { actual: NESCU.countPrefix (_ == 'c') (nes (SProxy :: SProxy "abaa"))
    , expected: 0
    }

  log "splitAt"
  assertEqual
    { actual: NESCU.splitAt 0 (nes (SProxy :: SProxy "a"))
    , expected: { before: Nothing, after: Just (nes (SProxy :: SProxy "a")) }
    }
  assertEqual
    { actual: NESCU.splitAt 1 (nes (SProxy :: SProxy "ab"))
    , expected: { before: Just (nes (SProxy :: SProxy "a")), after: Just (nes (SProxy :: SProxy "b")) }
    }
  assertEqual
    { actual: NESCU.splitAt 3 (nes (SProxy :: SProxy "aabcc"))
    , expected: { before: Just (nes (SProxy :: SProxy "aab")), after: Just (nes (SProxy :: SProxy "cc")) }
    }
  assertEqual
    { actual: NESCU.splitAt (-1) (nes (SProxy :: SProxy "abc"))
    , expected: { before: Nothing, after: Just (nes (SProxy :: SProxy "abc")) }
    }

nea :: Array ~> NEA.NonEmptyArray
nea = unsafePartial fromJust <<< NEA.fromArray
