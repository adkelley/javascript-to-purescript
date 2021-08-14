{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "tut14"
, dependencies =
  [ "bifunctors"
  , "console"
  , "contravariant"
  , "effect"
  , "integers"
  , "prelude"
  , "profunctor"
  , "psci-support"
  , "strings"
  , "tuples"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
