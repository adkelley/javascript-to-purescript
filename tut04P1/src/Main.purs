module Main where

import Prelude
import Effect (Effect)
import Effect.Console (log)
import Effect.Exception (Error, catchException, error, message, throwException)
import Effect.Random (randomInt)

type PortRange = { min :: Int, max :: Int }

validPorts :: PortRange
validPorts = { min: 2500,  max: 7500 }

isInvalidPort :: Int -> Boolean
isInvalidPort portNumber =
  (portNumber < validPorts.min || portNumber > validPorts.max)

throwWhenBadPort :: Int -> Effect Unit
throwWhenBadPort portNumber =
  when (isInvalidPort portNumber) $ throwException errorMessage
  where
    errorMessage =
       error $ "Error: expected a port number between " <>
               show validPorts.min <> " and " <> show validPorts.max

catchWhenBadPort :: Int -> Effect Unit
catchWhenBadPort portNumber =
  catchException printException $ throwWhenBadPort portNumber
  where
    printException :: Error -> Effect Unit
    printException e = log $ message e

main :: Effect Unit
main = do
  log "Use chain for composable error handling with nested Eithers - Part 1"
  
  -- Create 50% chance of generating invalid port numbers
  portNumber <- randomInt (validPorts.min - 2500) (validPorts.max + 2500)
  log $ "Our random port number is: " <> show portNumber

  -- Try commenting out catchWhenBadPort and uncommenting throwWhenBadPort
  -- to see throwException in action
  catchWhenBadPort portNumber
  -- throwWhenBadPort portNumber
