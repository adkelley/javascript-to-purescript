{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "tut04p2"
, dependencies =
  [ "console"
  , "effect"
  , "exceptions"
  , "foreign"
  , "node-fs"
  , "prelude"
  , "psci-support"
  , "simple-json"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
