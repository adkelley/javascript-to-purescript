module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Eff.Exception (EXCEPTION, catchException, error, message, throwException)
import Control.Monad.Eff.Random (RANDOM, randomInt)

type PortRange = { min :: Int, max :: Int }

validPorts :: PortRange
validPorts = { min: 2500,  max: 7500 }

invalidPort :: Int -> Boolean
invalidPort portNumber =
  (portNumber < validPorts.min || portNumber > validPorts.max)

throwWhenBadPort :: Int -> forall eff. Eff (err :: EXCEPTION | eff) Unit
throwWhenBadPort portNumber =
  when (invalidPort portNumber) $ throwException $
    error $ "Error: expected a port number between " <>
            show validPorts.min <> " and " <> show validPorts.max

catchWhenBadPort :: Int -> forall eff. Eff (console :: CONSOLE | eff) Unit
catchWhenBadPort portNumber =
  catchException printException (throwWhenBadPort portNumber)
  where
    printException e = log $ message e

main :: Eff (console :: CONSOLE, random :: RANDOM, err :: EXCEPTION) Unit
main = do
  log "Use chain for composable error handling with nested Eithers - Part 1"
  -- Create 50% chance of generating invalid port numbers
  portNumber <- randomInt (validPorts.min - 2500) (validPorts.max + 2500)
  log $ "Our random port number is: " <> show portNumber

  -- Try commenting out catchWhenBadPort and uncommenting throwWhenBadPort
  -- to see throwException in action
  catchWhenBadPort portNumber
  -- throwWhenBadPort portNumber
