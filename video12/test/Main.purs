module Test.Main where

import Preface

main :: Task Unit
main = sequence_ [ log "Hello, World!", log "Done"]
