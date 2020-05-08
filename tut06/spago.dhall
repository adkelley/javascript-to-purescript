{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "tut06"
, dependencies =
  [ "arrays", "console", "const", "effect", "prelude", "psci-support" ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
