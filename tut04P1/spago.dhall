{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "tut04p1"
, dependencies =
  [ "console"
  , "effect"
  , "exceptions"
  , "node-fs"
  , "prelude"
  , "psci-support"
  , "random"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
