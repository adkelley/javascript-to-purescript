-- | This module provides support for the
-- | PureScript interactive mode, PSCI.

module PSCI.Support where

import Prelude

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, logShow)
import Control.Monad.Eff.Unsafe (unsafeCoerceEff)

-- | The `Eval` class captures those types which can be
-- | evaluated in the REPL.
-- |
-- | There are (possibly overlapping) instances provided for
-- | the `Eff` type constructor and any `Show`able types.
class Eval a where
  eval :: a -> Eff (console :: CONSOLE) Unit

instance evalShow :: Show a => Eval a where
  eval = logShow

instance evalEff :: Eval a => Eval (Eff eff a) where
  eval x = do
    a <- unsafeCoerceEff x
    eval a
