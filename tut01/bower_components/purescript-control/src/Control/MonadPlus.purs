module Control.MonadPlus
  ( class MonadPlus
  , module Control.Alt
  , module Control.Alternative
  , module Control.Applicative
  , module Control.Apply
  , module Control.Bind
  , module Control.Monad
  , module Control.MonadZero
  , module Control.Plus
  , module Data.Functor
  ) where

import Control.Alt (class Alt, alt, (<|>))
import Control.Alternative (class Alternative)
import Control.Applicative (class Applicative, pure, liftA1, unless, when)
import Control.Apply (class Apply, apply, (*>), (<*), (<*>))
import Control.Bind (class Bind, bind, ifM, join, (<=<), (=<<), (>=>), (>>=))
import Control.Monad (class Monad, ap, liftM1)
import Control.MonadZero (class MonadZero, guard)
import Control.Plus (class Plus, empty)

import Data.Functor (class Functor, map, void, ($>), (<#>), (<$), (<$>))

-- | The `MonadPlus` type class has no members of its own but extends
-- | `MonadZero` with an additional law:
-- |
-- | - Distributivity: `(x <|> y) >>= f == (x >>= f) <|> (y >>= f)`
class MonadZero m <= MonadPlus m

instance monadPlusArray :: MonadPlus Array
