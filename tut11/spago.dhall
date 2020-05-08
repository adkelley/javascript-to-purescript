{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "tut11"
, dependencies =
  [ "console"
  , "control"
  , "effect"
  , "functions"
  , "identity"
  , "integers"
  , "lazy"
  , "prelude"
  , "psci-support"
  , "strings"
  , "unsafe-coerce"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
