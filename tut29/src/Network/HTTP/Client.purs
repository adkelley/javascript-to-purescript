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

get :: URI -> ExceptT Error Async String
get uri =
  ExceptT $ ContT $ \k -> runFn3 getImpl uri (k <<< Left) (k <<< Right)


-- Alternative approach. See: https://github.com/purescript-node/purescript-node-fs/blob/master/src/Node/FS/Async.purs

-- import Data.Function.Uncurried (Fn2, runFn2, Fn3, runFn3)


-- type Callback = Either Error String -> IO

-- type Failure = String -> Either Error String
-- type Success = String -> Either Error String

-- foreign import getImpl :: Fn2 URI Callback IO

-- foreign import handleCallbackImpl ::
--   Fn3 Failure Success Callback Callback

-- handleCallback :: Callback -> Callback
-- handleCallback = runFn3 handleCallbackImpl Left Right

-- get :: URI -> ExceptT Error Async String
-- get uri =
--   ExceptT $ ContT $ \k -> runFn2 getImpl uri $ handleCallback k
