{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "tut08"
, dependencies =
  [ "arrays", "console", "effect", "generics-rep", "prelude", "psci-support" ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
