{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "tut23"
, dependencies =
  [ "aff"
  , "console"
  , "effect"
  , "either"
  , "foldable-traversable"
  , "ordered-collections"
  , "prelude"
  , "psci-support"
  , "transformers"
  , "tuples"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
