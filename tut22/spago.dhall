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
  , "node-fs"
  , "prelude"
  , "psci-support"
  , "transformers"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
