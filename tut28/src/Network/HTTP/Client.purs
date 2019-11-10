module  Network.HTTP.Client (get) where

import Prelude

import Control.Monad.Cont.Trans (ContT(..))
import Control.Monad.Except.Trans (ExceptT(..))
import Data.Either (Either(..))
import Data.Function.Uncurried (Fn3, runFn3)
import Types (Async, Error, IO)

type URI = String
type Callback = String -> IO


foreign import getImpl :: Fn3 URI Callback Callback IO

-- foreign import handleCallbackImpl ::
--   Fn3 Failure Success Callback (Effect Unit)

-- handleCallback :: Callback -> Effect Unit
-- handleCallback cb = runFn3 handleCallbackImpl Left Right cb

get :: String -> ExceptT Error Async String
get uri =
  ExceptT $ ContT $ \k -> runFn3 getImpl uri (k <<< Left) (k <<< Right)
