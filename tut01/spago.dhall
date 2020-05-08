{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "tut01"
, dependencies =
  [ "console"
  , "effect"
  , "identity"
  , "integers"
  , "prelude"
  , "psci-support"
  , "strings"
  , "unsafe-coerce"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
