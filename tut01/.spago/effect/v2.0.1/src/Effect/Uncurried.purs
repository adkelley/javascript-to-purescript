-- | This module defines types for effectful uncurried functions, as well as
-- | functions for converting back and forth between them.
-- |
-- | This makes it possible to give a PureScript type to JavaScript functions
-- | such as this one:
-- |
-- | ```javascript
-- | function logMessage(level, message) {
-- |   console.log(level + ": " + message);
-- | }
-- | ```
-- |
-- | In particular, note that `logMessage` performs effects immediately after
-- | receiving all of its parameters, so giving it the type `Data.Function.Fn2
-- | String String Unit`, while convenient, would effectively be a lie.
-- |
-- | One way to handle this would be to convert the function into the normal
-- | PureScript form (namely, a curried function returning an Effect action),
-- | and performing the marshalling in JavaScript, in the FFI module, like this:
-- |
-- | ```purescript
-- | -- In the PureScript file:
-- | foreign import logMessage :: String -> String -> Effect Unit
-- | ```
-- |
-- | ```javascript
-- | // In the FFI file:
-- | exports.logMessage = function(level) {
-- |   return function(message) {
-- |     return function() {
-- |       logMessage(level, message);
-- |     };
-- |   };
-- | };
-- | ```
-- |
-- | This method, unfortunately, turns out to be both tiresome and error-prone.
-- | This module offers an alternative solution. By providing you with:
-- |
-- |  * the ability to give the real `logMessage` function a PureScript type,
-- |    and
-- |  * functions for converting between this form and the normal PureScript
-- |    form,
-- |
-- | the FFI boilerplate is no longer needed. The previous example becomes:
-- |
-- | ```purescript
-- | -- In the PureScript file:
-- | foreign import logMessageImpl :: EffectFn2 String String Unit
-- | ```
-- |
-- | ```javascript
-- | // In the FFI file:
-- | exports.logMessageImpl = logMessage
-- | ```
-- |
-- | You can then use `runEffectFn2` to provide a nicer version:
-- |
-- | ```purescript
-- | logMessage :: String -> String -> Effect Unit
-- | logMessage = runEffectFn2 logMessageImpl
-- | ```
-- |
-- | (note that this has the same type as the original `logMessage`).
-- |
-- | Effectively, we have reduced the risk of errors by moving as much code into
-- | PureScript as possible, so that we can leverage the type system. Hopefully,
-- | this is a little less tiresome too.
-- |
-- | Here's a slightly more advanced example. Here, because we are using
-- | callbacks, we need to use `mkEffectFn{N}` as well.
-- |
-- | Suppose our `logMessage` changes so that it sometimes sends details of the
-- | message to some external server, and in those cases, we want the resulting
-- | `HttpResponse` (for whatever reason).
-- |
-- | ```javascript
-- | function logMessage(level, message, callback) {
-- |   console.log(level + ": " + message);
-- |   if (level > LogLevel.WARN) {
-- |     LogAggregatorService.post("/logs", {
-- |       level: level,
-- |       message: message
-- |     }, callback);
-- |   } else {
-- |     callback(null);
-- |   }
-- | }
-- | ```
-- |
-- | The import then looks like this:
-- | ```purescript
-- | foreign import logMessageImpl
-- |  EffectFn3
-- |    String
-- |    String
-- |    (EffectFn1 (Nullable HttpResponse) Unit)
-- |    Unit
-- | ```
-- |
-- | And, as before, the FFI file is extremely simple:
-- |
-- | ```javascript
-- | exports.logMessageImpl = logMessage
-- | ```
-- |
-- | Finally, we use `runEffectFn{N}` and `mkEffectFn{N}` for a more comfortable
-- | PureScript version:
-- |
-- | ```purescript
-- | logMessage ::
-- |   String ->
-- |   String ->
-- |   (Nullable HttpResponse -> Effect Unit) ->
-- |   Effect Unit
-- | logMessage level message callback =
-- |   runEffectFn3 logMessageImpl level message (mkEffectFn1 callback)
-- | ```
-- |
-- | The general naming scheme for functions and types in this module is as
-- | follows:
-- |
-- | * `EffectFn{N}` means, an uncurried function which accepts N arguments and
-- |   performs some effects. The first N arguments are the actual function's
-- |   argument. The last type argument is the return type.
-- | * `runEffectFn{N}` takes an `EffectFn` of N arguments, and converts it into
-- |   the normal PureScript form: a curried function which returns an Effect
-- |   action.
-- | * `mkEffectFn{N}` is the inverse of `runEffectFn{N}`. It can be useful for
-- |   callbacks.
-- |

module Effect.Uncurried where

import Effect (Effect)

foreign import data EffectFn1 :: Type -> Type -> Type
foreign import data EffectFn2 :: Type -> Type -> Type -> Type
foreign import data EffectFn3 :: Type -> Type -> Type -> Type -> Type
foreign import data EffectFn4 :: Type -> Type -> Type -> Type -> Type -> Type
foreign import data EffectFn5 :: Type -> Type -> Type -> Type -> Type -> Type -> Type
foreign import data EffectFn6 :: Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type
foreign import data EffectFn7 :: Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type
foreign import data EffectFn8 :: Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type
foreign import data EffectFn9 :: Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type
foreign import data EffectFn10 :: Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type

foreign import mkEffectFn1 :: forall a r.
  (a -> Effect r) -> EffectFn1 a r
foreign import mkEffectFn2 :: forall a b r.
  (a -> b -> Effect r) -> EffectFn2 a b r
foreign import mkEffectFn3 :: forall a b c r.
  (a -> b -> c -> Effect r) -> EffectFn3 a b c r
foreign import mkEffectFn4 :: forall a b c d r.
  (a -> b -> c -> d -> Effect r) -> EffectFn4 a b c d r
foreign import mkEffectFn5 :: forall a b c d e r.
  (a -> b -> c -> d -> e -> Effect r) -> EffectFn5 a b c d e r
foreign import mkEffectFn6 :: forall a b c d e f r.
  (a -> b -> c -> d -> e -> f -> Effect r) -> EffectFn6 a b c d e f r
foreign import mkEffectFn7 :: forall a b c d e f g r.
  (a -> b -> c -> d -> e -> f -> g -> Effect r) -> EffectFn7 a b c d e f g r
foreign import mkEffectFn8 :: forall a b c d e f g h r.
  (a -> b -> c -> d -> e -> f -> g -> h -> Effect r) -> EffectFn8 a b c d e f g h r
foreign import mkEffectFn9 :: forall a b c d e f g h i r.
  (a -> b -> c -> d -> e -> f -> g -> h -> i -> Effect r) -> EffectFn9 a b c d e f g h i r
foreign import mkEffectFn10 :: forall a b c d e f g h i j r.
  (a -> b -> c -> d -> e -> f -> g -> h -> i -> j -> Effect r) -> EffectFn10 a b c d e f g h i j r

foreign import runEffectFn1 :: forall a r.
  EffectFn1 a r -> a -> Effect r
foreign import runEffectFn2 :: forall a b r.
  EffectFn2 a b r -> a -> b -> Effect r
foreign import runEffectFn3 :: forall a b c r.
  EffectFn3 a b c r -> a -> b -> c -> Effect r
foreign import runEffectFn4 :: forall a b c d r.
  EffectFn4 a b c d r -> a -> b -> c -> d -> Effect r
foreign import runEffectFn5 :: forall a b c d e r.
  EffectFn5 a b c d e r -> a -> b -> c -> d -> e -> Effect r
foreign import runEffectFn6 :: forall a b c d e f r.
  EffectFn6 a b c d e f r -> a -> b -> c -> d -> e -> f -> Effect r
foreign import runEffectFn7 :: forall a b c d e f g r.
  EffectFn7 a b c d e f g r -> a -> b -> c -> d -> e -> f -> g -> Effect r
foreign import runEffectFn8 :: forall a b c d e f g h r.
  EffectFn8 a b c d e f g h r -> a -> b -> c -> d -> e -> f -> g -> h -> Effect r
foreign import runEffectFn9 :: forall a b c d e f g h i r.
  EffectFn9 a b c d e f g h i r -> a -> b -> c -> d -> e -> f -> g -> h -> i -> Effect r
foreign import runEffectFn10 :: forall a b c d e f g h i j r.
  EffectFn10 a b c d e f g h i j r -> a -> b -> c -> d -> e -> f -> g -> h -> i -> j -> Effect r
