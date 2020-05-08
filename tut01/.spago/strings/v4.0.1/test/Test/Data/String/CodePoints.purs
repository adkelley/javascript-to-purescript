module Test.Data.String.CodePoints (testStringCodePoints) where

import Prelude

import Data.Enum (fromEnum, toEnum)
import Data.Maybe (Maybe(..), fromJust)
import Data.String.CodePoints as SCP
import Data.String.Pattern (Pattern(..))
import Effect (Effect)
import Effect.Console (log)
import Partial.Unsafe (unsafePartial)
import Test.Assert (assertEqual)

str :: String
str = "a\xDC00\xD800\xD800\x16805\x16A06\&z"

testStringCodePoints :: Effect Unit
testStringCodePoints = do

  log "show"
  assertEqual
    { actual: map show (SCP.codePointAt 0 str)
    , expected: Just "(CodePoint 0x61)"
    }
  assertEqual
    { actual: map show (SCP.codePointAt 1 str)
    , expected: Just "(CodePoint 0xDC00)"
    }
  assertEqual
    { actual: map show (SCP.codePointAt 2 str)
    , expected: Just "(CodePoint 0xD800)"
    }
  assertEqual
    { actual: map show (SCP.codePointAt 3 str)
    , expected: Just "(CodePoint 0xD800)"
    }
  assertEqual
    { actual: map show (SCP.codePointAt 4 str)
    , expected: Just "(CodePoint 0x16805)"
    }
  assertEqual
    { actual: map show (SCP.codePointAt 5 str)
    , expected: Just "(CodePoint 0x16A06)"
    }
  assertEqual
    { actual: map show (SCP.codePointAt 6 str)
    , expected: Just "(CodePoint 0x7A)"
    }

  log "codePointFromChar"
  assertEqual
    { actual: Just (SCP.codePointFromChar 'A')
    , expected: (toEnum 65)
    }
  assertEqual
    { actual: (SCP.codePointFromChar <$> toEnum 0)
    , expected: toEnum 0
    }
  assertEqual
    { actual: (SCP.codePointFromChar <$> toEnum 0xFFFF)
    , expected: toEnum 0xFFFF
    }

  log "singleton"
  assertEqual
    { actual: (SCP.singleton <$> toEnum 0x30)
    , expected: Just "0"
    }
  assertEqual
    { actual: (SCP.singleton <$> toEnum 0x16805)
    , expected: Just "\x16805"
    }

  log "codePointAt"
  assertEqual
    { actual: SCP.codePointAt (-1) str
    , expected: Nothing
    }
  assertEqual
    { actual: SCP.codePointAt 0 str
    , expected: (toEnum 0x61)
    }
  assertEqual
    { actual: SCP.codePointAt 1 str
    , expected: (toEnum 0xDC00)
    }
  assertEqual
    { actual: SCP.codePointAt 2 str
    , expected: (toEnum 0xD800)
    }
  assertEqual
    { actual: SCP.codePointAt 3 str
    , expected: (toEnum 0xD800)
    }
  assertEqual
    { actual: SCP.codePointAt 4 str
    , expected: (toEnum 0x16805)
    }
  assertEqual
    { actual: SCP.codePointAt 5 str
    , expected: (toEnum 0x16A06)
    }
  assertEqual
    { actual: SCP.codePointAt 6 str
    , expected: (toEnum 0x7A)
    }
  assertEqual
    { actual: SCP.codePointAt 7 str
    , expected: Nothing
    }

  log "uncons"
  assertEqual
    { actual: SCP.uncons str
    , expected: Just {head: cp 0x61, tail:  "\xDC00\xD800\xD800\x16805\x16A06\&z"}
    }
  assertEqual
    { actual: SCP.uncons (SCP.drop 1 str)
    , expected: Just {head: cp 0xDC00, tail: "\xD800\xD800\x16805\x16A06\&z"}
    }
  assertEqual
    { actual: SCP.uncons (SCP.drop 2 str)
    , expected: Just {head: cp 0xD800, tail: "\xD800\x16805\x16A06\&z"}
    }
  assertEqual
    { actual: SCP.uncons (SCP.drop 3 str)
    , expected: Just {head: cp 0xD800, tail: "\x16805\x16A06\&z"}
    }
  assertEqual
    { actual: SCP.uncons (SCP.drop 4 str)
    , expected: Just {head: cp 0x16805, tail: "\x16A06\&z"}
    }
  assertEqual
    { actual: SCP.uncons (SCP.drop 5 str)
    , expected: Just {head: cp 0x16A06, tail: "z"}
    }
  assertEqual
    { actual: SCP.uncons (SCP.drop 6 str)
    , expected: Just {head: cp 0x7A, tail: ""}
    }
  assertEqual
    { actual: SCP.uncons ""
    , expected: Nothing
    }

  log "length"
  assertEqual
    { actual: SCP.length ""
    , expected: 0
    }
  assertEqual
    { actual: SCP.length "a"
    , expected: 1
    }
  assertEqual
    { actual: SCP.length "ab"
    , expected: 2
    }
  assertEqual
    { actual: SCP.length str
    , expected: 7
    }

  log "countPrefix"
  assertEqual
    { actual: SCP.countPrefix (\_ -> true) ""
    , expected: 0
    }
  assertEqual
    { actual: SCP.countPrefix (\_ -> false) str
    , expected: 0
    }
  assertEqual
    { actual: SCP.countPrefix (\_ -> true) str
    , expected: 7
    }
  assertEqual
    { actual: SCP.countPrefix (\x -> fromEnum x < 0xFFFF) str
    , expected: 4
    }
  assertEqual
    { actual: SCP.countPrefix (\x -> fromEnum x < 0xDC00) str
    , expected: 1
    }

  log "indexOf"
  assertEqual
    { actual: SCP.indexOf (Pattern "") ""
    , expected: Just 0
    }
  assertEqual
    { actual: SCP.indexOf (Pattern "") str
    , expected: Just 0
    }
  assertEqual
    { actual: SCP.indexOf (Pattern str) str
      , expected: Just 0
      }
  assertEqual
    { actual: SCP.indexOf (Pattern "a") str
    , expected: Just 0
    }
  assertEqual
    { actual: SCP.indexOf (Pattern "\xDC00\xD800\xD800") str
    , expected: Just 1
    }
  assertEqual
    { actual: SCP.indexOf (Pattern "\xD800") str
    , expected: Just 2
    }
  assertEqual
    { actual: SCP.indexOf (Pattern "\xD800\xD800") str
    , expected: Just 2
    }
  assertEqual
    { actual: SCP.indexOf (Pattern "\xD800\xD81A") str
    , expected: Just 3
    }
  assertEqual
    { actual: SCP.indexOf (Pattern "\xD800\x16805") str
    , expected: Just 3
    }
  assertEqual
    { actual: SCP.indexOf (Pattern "\x16805") str
    , expected: Just 4
    }
  assertEqual
    { actual: SCP.indexOf (Pattern "\x16A06") str
    , expected: Just 5
    }
  assertEqual
    { actual: SCP.indexOf (Pattern "z") str
    , expected: Just 6
    }
  assertEqual
    { actual: SCP.indexOf (Pattern "\0") str
    , expected: Nothing
    }
  assertEqual
    { actual: SCP.indexOf (Pattern "\xD81A") str
    , expected: Just 4
    }

  log "indexOf'"
  assertEqual
    { actual: SCP.indexOf' (Pattern "") 0 ""
    , expected: Just 0
    }
  assertEqual
    { actual: SCP.indexOf' (Pattern str) 0 str
    , expected: Just 0
    }
  assertEqual
    { actual: SCP.indexOf' (Pattern str) 1 str
    , expected: Nothing
    }
  assertEqual
    { actual: SCP.indexOf' (Pattern "a") 0 str
    , expected: Just 0
    }
  assertEqual
    { actual: SCP.indexOf' (Pattern "a") 1 str
    , expected: Nothing
    }
  assertEqual
    { actual: SCP.indexOf' (Pattern "z") 0 str
    , expected: Just 6
    }
  assertEqual
    { actual: SCP.indexOf' (Pattern "z") 1 str
    , expected: Just 6
    }
  assertEqual
    { actual: SCP.indexOf' (Pattern "z") 2 str
    , expected: Just 6
    }
  assertEqual
    { actual: SCP.indexOf' (Pattern "z") 3 str
    , expected: Just 6
    }
  assertEqual
    { actual: SCP.indexOf' (Pattern "z") 4 str
    , expected: Just 6
    }
  assertEqual
    { actual: SCP.indexOf' (Pattern "z") 5 str
    , expected: Just 6
    }
  assertEqual
    { actual: SCP.indexOf' (Pattern "z") 6 str
    , expected: Just 6
    }
  assertEqual
    { actual: SCP.indexOf' (Pattern "z") 7 str
    , expected: Nothing
    }

  log "lastIndexOf"
  assertEqual
    { actual: SCP.lastIndexOf (Pattern "") ""
    , expected: Just 0
    }
  assertEqual
    { actual: SCP.lastIndexOf (Pattern "") str
    , expected: Just 7
    }
  assertEqual
    { actual: SCP.lastIndexOf (Pattern str) str
    , expected: Just 0
    }
  assertEqual
    { actual: SCP.lastIndexOf (Pattern "a") str
    , expected: Just 0
    }
  assertEqual
    { actual: SCP.lastIndexOf (Pattern "\xDC00\xD800\xD800") str
    , expected: Just 1
    }
  assertEqual
    { actual: SCP.lastIndexOf (Pattern "\xD800") str
    , expected: Just 3
    }
  assertEqual
    { actual: SCP.lastIndexOf (Pattern "\xD800\xD800") str
    , expected: Just 2
    }
  assertEqual
    { actual: SCP.lastIndexOf (Pattern "\xD800\xD81A") str
    , expected: Just 3
    }
  assertEqual
    { actual: SCP.lastIndexOf (Pattern "\xD800\x16805") str
    , expected: Just 3
    }
  assertEqual
    { actual: SCP.lastIndexOf (Pattern "\x16805") str
    , expected: Just 4
    }
  assertEqual
    { actual: SCP.lastIndexOf (Pattern "\x16A06") str
    , expected: Just 5
    }
  assertEqual
    { actual: SCP.lastIndexOf (Pattern "z") str
    , expected: Just 6
    }
  assertEqual
    { actual: SCP.lastIndexOf (Pattern "\0") str
    , expected: Nothing
    }
  assertEqual
    { actual: SCP.lastIndexOf (Pattern "\xD81A") str
    , expected: Just 5
    }

  log "lastIndexOf'"
  assertEqual
    { actual: SCP.lastIndexOf' (Pattern "") 0 ""
    , expected: Just 0
    }
  assertEqual
    { actual: SCP.lastIndexOf' (Pattern str) 0 str
    , expected: Just 0
    }
  assertEqual
    { actual: SCP.lastIndexOf' (Pattern str) 1 str
    , expected: Just 0
    }
  assertEqual
    { actual: SCP.lastIndexOf' (Pattern "a") 0 str
    , expected: Just 0
    }
  assertEqual
    { actual: SCP.lastIndexOf' (Pattern "a") 7 str
    , expected: Just 0
    }
  assertEqual
    { actual: SCP.lastIndexOf' (Pattern "z") 0 str
    , expected: Nothing
    }
  assertEqual
    { actual: SCP.lastIndexOf' (Pattern "z") 1 str
    , expected: Nothing
    }
  assertEqual
    { actual: SCP.lastIndexOf' (Pattern "z") 2 str
    , expected: Nothing
    }
  assertEqual
    { actual: SCP.lastIndexOf' (Pattern "z") 3 str
    , expected: Nothing
    }
  assertEqual
    { actual: SCP.lastIndexOf' (Pattern "z") 4 str
    , expected: Nothing
    }
  assertEqual
    { actual: SCP.lastIndexOf' (Pattern "z") 5 str
    , expected: Nothing
    }
  assertEqual
    { actual: SCP.lastIndexOf' (Pattern "z") 6 str
    , expected: Just 6
    }
  assertEqual
    { actual: SCP.lastIndexOf' (Pattern "z") 7 str
    , expected: Just 6
    }
  assertEqual
    { actual: SCP.lastIndexOf' (Pattern "\xD800") 7 str
    , expected: Just 3
    }
  assertEqual
    { actual: SCP.lastIndexOf' (Pattern "\xD800") 6 str
    , expected: Just 3
    }
  assertEqual
    { actual: SCP.lastIndexOf' (Pattern "\xD800") 5 str
    , expected: Just 3
    }
  assertEqual
    { actual: SCP.lastIndexOf' (Pattern "\xD800") 4 str
    , expected: Just 3
    }
  assertEqual
    { actual: SCP.lastIndexOf' (Pattern "\xD800") 3 str
    , expected: Just 3
    }
  assertEqual
    { actual: SCP.lastIndexOf' (Pattern "\xD800") 2 str
    , expected: Just 2
    }
  assertEqual
    { actual: SCP.lastIndexOf' (Pattern "\xD800") 1 str
    , expected: Nothing
    }
  assertEqual
    { actual: SCP.lastIndexOf' (Pattern "\xD800") 0 str
    , expected: Nothing
    }
  assertEqual
    { actual: SCP.lastIndexOf' (Pattern "\x16A06") 7 str
    , expected: Just 5
    }
  assertEqual
    { actual: SCP.lastIndexOf' (Pattern "\x16A06") 6 str
    , expected: Just 5
    }
  assertEqual
    { actual: SCP.lastIndexOf' (Pattern "\x16A06") 5 str
    , expected: Just 5
    }
  assertEqual
    { actual: SCP.lastIndexOf' (Pattern "\x16A06") 4 str
    , expected: Nothing
    }
  assertEqual
    { actual: SCP.lastIndexOf' (Pattern "\x16A06") 3 str
    , expected: Nothing
    }

  log "take"
  assertEqual
    { actual: SCP.take (-1) str
    , expected: ""
    }
  assertEqual
    { actual: SCP.take 0 str
    , expected: ""
    }
  assertEqual
    { actual: SCP.take 1 str
    , expected: "a"
    }
  assertEqual
    { actual: SCP.take 2 str
    , expected: "a\xDC00"
    }
  assertEqual
    { actual: SCP.take 3 str
    , expected: "a\xDC00\xD800"
    }
  assertEqual
    { actual: SCP.take 4 str
    , expected: "a\xDC00\xD800\xD800"
    }
  assertEqual
    { actual: SCP.take 5 str
    , expected: "a\xDC00\xD800\xD800\x16805"
    }
  assertEqual
    { actual: SCP.take 6 str
    , expected: "a\xDC00\xD800\xD800\x16805\x16A06"
    }
  assertEqual
    { actual: SCP.take 7 str
    , expected: str
    }
  assertEqual
    { actual: SCP.take 8 str
    , expected: str
    }

  log "takeWhile"
  assertEqual
    { actual: SCP.takeWhile (\_ -> true) str
    , expected: str
    }
  assertEqual
    { actual: SCP.takeWhile (\_ -> false) str
    , expected: ""
    }
  assertEqual
    { actual: SCP.takeWhile (\c -> fromEnum c < 0xFFFF) str
    , expected: "a\xDC00\xD800\xD800"
    }
  assertEqual
    { actual: SCP.takeWhile (\c -> fromEnum c < 0xDC00) str
    , expected: "a"
    }

  log "drop"
  assertEqual
    { actual: SCP.drop (-1) str
    , expected: str
    }
  assertEqual
    { actual: SCP.drop 0 str
    , expected: str
    }
  assertEqual
    { actual: SCP.drop 1 str
    , expected: "\xDC00\xD800\xD800\x16805\x16A06\&z"
    }
  assertEqual
    { actual: SCP.drop 2 str
    , expected: "\xD800\xD800\x16805\x16A06\&z"
    }
  assertEqual
    { actual: SCP.drop 3 str
    , expected: "\xD800\x16805\x16A06\&z"
    }
  assertEqual
    { actual: SCP.drop 4 str
    , expected: "\x16805\x16A06\&z"
    }
  assertEqual
    { actual: SCP.drop 5 str
    , expected: "\x16A06\&z"
    }
  assertEqual
    { actual: SCP.drop 6 str
    , expected: "z"
    }
  assertEqual
    { actual: SCP.drop 7 str
    , expected: ""
    }
  assertEqual
    { actual: SCP.drop 8 str
    , expected: ""
    }

  log "dropWhile"
  assertEqual
    { actual: SCP.dropWhile (\_ -> true) str
    , expected: ""
    }
  assertEqual
    { actual: SCP.dropWhile (\_ -> false) str
    , expected: str
    }
  assertEqual
    { actual: SCP.dropWhile (\c -> fromEnum c < 0xFFFF) str
    , expected: "\x16805\x16A06\&z"
    }
  assertEqual
    { actual: SCP.dropWhile (\c -> fromEnum c < 0xDC00) str
    , expected: "\xDC00\xD800\xD800\x16805\x16A06\&z"
    }

  log "splitAt"
  assertEqual
    { actual: SCP.splitAt 0 ""
    , expected: {before: "", after: "" }
    }
  assertEqual
    { actual: SCP.splitAt 1 ""
    , expected: {before: "", after: "" }
    }
  assertEqual
    { actual: SCP.splitAt 0 "a"
    , expected: {before: "", after: "a"}
    }
  assertEqual
    { actual: SCP.splitAt 1 "ab"
    , expected: {before: "a", after: "b"}
    }
  assertEqual
    { actual: SCP.splitAt 3 "aabcc"
    , expected: {before: "aab", after: "cc"}
    }
  assertEqual
    { actual: SCP.splitAt (-1) "abc"
    , expected: {before: "", after: "abc"}
    }
  assertEqual
    { actual: SCP.splitAt 0 str
    , expected: {before: "", after: str}
    }
  assertEqual
    { actual: SCP.splitAt 1 str
    , expected: {before: "a", after: "\xDC00\xD800\xD800\x16805\x16A06\&z"}
    }
  assertEqual
    { actual: SCP.splitAt 2 str
    , expected: {before: "a\xDC00", after: "\xD800\xD800\x16805\x16A06\&z"}
    }
  assertEqual
    { actual: SCP.splitAt 3 str
    , expected: {before: "a\xDC00\xD800", after: "\xD800\x16805\x16A06\&z"}
    }
  assertEqual
    { actual: SCP.splitAt 4 str
    , expected: {before: "a\xDC00\xD800\xD800", after: "\x16805\x16A06\&z"}
    }
  assertEqual
    { actual: SCP.splitAt 5 str
    , expected: {before: "a\xDC00\xD800\xD800\x16805", after: "\x16A06\&z"}
    }
  assertEqual
    { actual: SCP.splitAt 6 str
    , expected: {before: "a\xDC00\xD800\xD800\x16805\x16A06", after: "z"}
    }
  assertEqual
    { actual: SCP.splitAt 7 str
    , expected: {before: str, after: ""}
    }
  assertEqual
    { actual: SCP.splitAt 8 str
    , expected: {before: str, after: ""}
    }

cp :: Int -> SCP.CodePoint
cp = unsafePartial fromJust <<< toEnum
