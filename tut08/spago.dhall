{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "tut08"
, dependencies =
  [ "console"
  , "effect"
  , "foldable-traversable"
  , "maybe"
  , "prelude"
  , "psci-support"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
