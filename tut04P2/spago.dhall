{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "tut04p2"
, dependencies =
  [ "console"
  , "effect"
  , "either"
  , "exceptions"
  , "foreign"
  , "lists"
  , "node-buffer"
  , "node-fs"
  , "prelude"
  , "psci-support"
  , "simple-json"
  , "transformers"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
