{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "tut23"
, dependencies =
  [ "aff"
  , "console"
  , "effect"
  , "ordered-collections"
  , "prelude"
  , "psci-support"
  , "transformers"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
