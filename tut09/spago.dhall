{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "tut09"
, dependencies =
  [ "arrays"
  , "console"
  , "effect"
  , "either"
  , "filterable"
  , "foldable-traversable"
  , "maybe"
  , "newtype"
  , "orders"
  , "partial"
  , "prelude"
  , "psci-support"
  , "strings"
  , "tuples"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
