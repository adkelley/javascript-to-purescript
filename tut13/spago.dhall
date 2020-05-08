{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "tut13"
, dependencies =
  [ "aff"
  , "console"
  , "effect"
  , "exceptions"
  , "node-fs"
  , "node-fs-aff"
  , "prelude"
  , "psci-support"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
