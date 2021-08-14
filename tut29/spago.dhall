{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "tut28"
, dependencies =
  [ "aff"
  , "arrays"
  , "console"
  , "effect"
  , "either"
  , "foldable-traversable"
  , "functions"
  , "maybe"
  , "node-process"
  , "prelude"
  , "psci-support"
  , "simple-json"
  , "transformers"
  , "tuples"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
