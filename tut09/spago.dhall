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
  , "newtype"
  , "orders"
  , "prelude"
  , "psci-support"
  , "strings"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
