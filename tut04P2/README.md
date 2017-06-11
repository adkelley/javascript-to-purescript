# Use bind for composable error handling with nested Eithers
## Part 2 - Pulling it all together

![series banner](../resources/glitched-abstract.jpg)

> *Note: This is* **Tutorial 4 - Part 2** *in the series* **Make the leap from JavaScript to PureScript** *. Be sure*
> *to read the series introduction where we cover the goals & outline, and the installation,*
> *compilation, & running of PureScript. I will be publishing a new tutorial approximately*
> *once-per-week. So come back often, there is a lot more to come!*

> [<< Introduction](https://github.com/adkelley/javascript-to-purescript) [< Tutorial 4P1](https://github.com/adkelley/javascript-to-purescript/tree/master/tut04P1)

The series outline and javascript code samples were borrowed with permission from the egghead.io course [Professor Frisby Introduces Composable Functional JavaScript](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) by
[Brian Lonsdorf](https://github.com/DrBoolean) - thank you, Brian! A fundamental assumption of each tutorial is that you've watched his video before tackling the equivalent PureScript abstraction featured in this tutorial.  Brian covers the featured concepts extremely well, and I feel it's better that you understand its implementation in the comfort of JavaScript. Let me mention that if you read something that you feel could be explained better, or a code example that needs refactoring, then please let me know via a comment or send me a pull request on [Github](https://github.com/adkelley/javascript-to-purescript/tree/master/tut04P1).

## Compiler release update
Since I began writing these tutorials, there has been a couple [release updates](https://github.com/purescript/purescript/releases) to the PureScript compiler. So starting with this tutorial, the package declarations in `bower.json` have been updated to support compiler version 0.10.5 and are not backward compatible.  So be sure to update PureScript and [pulp](https://github.com/bodil/pulp) to their latest release.  Here's how I do it:

```
npm update -g purescript pulp

```

## Introduction

In [Part 1]((https://github.com/adkelley/javascript-to-purescript/tree/master/tut04P1), recall that a function or expression creates a side effect whenever it modifies some state outside its scope, or it has an observable interaction with the outside world.  We don't eliminate them because side effects help to write useful code.  Instead, we represent them in the type system to distinguish them from pure computations.  One benefit is that future maintainers will recognize side effects in our code more readily.

There is a particular class of side effects produced by the runtime system, called 'native' side effects. Console IO, random number generation, and file IO are examples of native side effects.  I covered console IO and random number generation in Part 1; now we'll learn file IO in PureScript in this tutorial.  But there's more - I'm going to sync back up with Brian’s [4th tutorial](https://egghead.io/lessons/javascript-composable-error-handling-with-either) by showing how `chain` can be used to compose nested `Either`s together in PureScript.

## Try/Catch Pattern

Try/Catch is a popular design pattern for exception handling.  A `try` will test a block of code for errors, and the accompanying `catch` block will handle those errors.  Using `readFileSync` from Node.js, the JavaScript code example given below reads and returns a port number from the configuration file `config.js`.  If all goes well, the try block will return the port number.  But if readFileSync or JSON.parse fails, then the `catch` block will return a default port number of 3000.

```JavaScript
const fs = require('fs')

const getPort = () => {
  try {
    const str = fs.readFileSync('config.json')
    const config = JSON.parse(str)
    return config.port
  } catch(e) {
    return 3000
  }
}

const result = getPort()
console.log(result)
```

Besides the methods themselves, notice there is nothing explicit in JavaScript to tell maintainers that there are two or possibly three side-effects - console IO, file IO, and maybe an exception.  Now you may be entirely comfortable with that, and it is not your fault because there is no type system in JavaScript.  But on bigger JavaScript projects, I will create a comment that declares the side effects, and I try to confine the functions that create them to the outer edges of my code.

## File IO in PureScript

Let's learn how to read a file in PureScript using the `Node.FS` modules from the `purescript-node-fs` package.  Again, file IO is a native side effect and, as I showed in Part 1, we use the Eff Monad to wrap them.  Don't worry if you have not encountered monads yet.  I think it is better to learn by showing concrete examples first to develop an intuition about how monads work.  Later on, you can go to the literature to get a more formal appreciation.  In the code example below, we have our usual import suspects such as `Prelude`.  But I have also added some new ones to support reading the `config.json` file. You can check them out in [pursuit](https://pursuit.purescript.org).

```haskell
module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, logShow)
import Control.Monad.Eff.Exception (EXCEPTION, try)
import Node.Encoding (Encoding(..))
import Node.FS (FS)
import Node.FS.Sync (readTextFile)

pathToFile :: String
pathToFile = "./resources/config.json"

main :: forall e. Eff (fs :: FS, console :: CONSOLE, exception :: EXCEPTION | e) Unit
main =
  (try $ readTextFile UTF8 pathToFile) >>= logShow
```

PureScript's type system makes it explicit about the side effects we generate.  Thus, in the `main` function, the effect monad `Eff` wraps and declares the following effects.  The file system `FS` effect comes from reading the text file, and the `CONSOLE` effect if for logging the `Either` constructor from (try $ `readTextFile`) to the console.  Finally, if something goes wrong, then raise an exception with the `EXCEPTION` effect.

Using the PureScript [REPL](http://www.purescript.org/learn/getting-started/) or directly from your [editor](https://github.com/purescript/purescript/wiki/Editor-and-tool-support), you can query the type declaration to find that `(try $ readTextFile)` returns `Eff FS (Right String)` on success or `Eff EXCEPTION (Left Error)` when there is an exception.  On account of the side effect created from `readTextFile`, the Eff monad is needed to wrap the FS or EXCEPTION effect together with the `Either` constructor.

Now don't gloss over that inconspicuous bind operator `(>>=)` connecting `(try $ readTextFile)` to `logShow`.  You will see `bind` often in these tutorials.  We use it to take a construct out of a monad to enable function application on that value or object.  In our example, `bind` takes the `Either Error String` out of the Eff monad to allow logging to the console using `logShow`. If `readTextFile` is successful then `(Right "{\"port\": 8888}\n")` is logged, otherwise you will see `(Left Error: ENOENT: no such file or directory, . . .)`. Finally, the `main` function will terminate by returning `Unit` (i.e., nothing), signifying that the program ended correctly.


## Using chain to compose nested Eithers

We are ready to handle the potential for nested `Either` constructors stemming from multiple error tests.  More intuitively, assuming we don't take care of it, after conducting a second error test, we end up with a `Right` of a `Left` of some error, or we have a `Right` of another `Right`.  Unwrapping multiple inner values is problematic, so it is best to manage it as we go along.  In the case of nested Eithers, we use the `chain` function.  Think of it like `map` from previous tutorials, except `chain` un-nests the resulting nested object and wraps it back up the way we want it.  Here is the type definition:

`chain :: forall a b e. (a -> Either e b) ->  Either e a -> Either e b`

The first argument to `chain` is an error test function that takes a polymorphic value `a` and maps it to a `Left e` or `Right b` where `e` is some polymorphic error value type, and `b` is another polymorphic value type. Note that the type declarations in `chain` are polymorphic so that you can handle Either constructors with different types at different times.  Our second argument is a `Right a` or `Left e`, computed from the last error test function before calling `chain`.  And finally, after executing the current exception handler (i.e., the first argument), we output a `Left e` or `Right b`, depending on an error or success.

With the intuition for `chain` under our belt, let's look at the final PureScript code example:

```Haskell
module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log, logShow)
import Control.Monad.Eff.Exception (EXCEPTION, Error, error, try)
import Control.Monad.Except (runExcept)
import Data.Either (Either(..), either)
import Data.Foreign (unsafeFromForeign)
import Data.Foreign.JSON (parseJSON)
import Node.Encoding (Encoding(..))
import Node.FS (FS)
import Node.FS.Sync (readTextFile)
import Data.List.NonEmpty (head)

pathToFile :: String
pathToFile = "./resources/config.json"

newtype Port = Port { port :: Int }
instance showPort :: Show Port where
  show (Port { port }) = show port

defaultPort :: Port
defaultPort = Port { port: 3000 }

parsePort :: String -> Either Error Port
parsePort port =
  case parsed of
    Left nel -> Left $ error $ show $ head nel
    Right x -> Right $ unsafeFromForeign x :: Port
  where parsed = runExcept $ parseJSON port

chain :: forall a b e. (a -> Either e b) ->  Either e a -> Either e b
chain f  = either (\e -> Left e) (\x -> (f x))

getPort :: forall eff. Eff (fs :: FS, exception :: EXCEPTION | eff) Port
getPort =
  (try $ readTextFile UTF8 pathToFile) >>=
  chain parsePort >>>
  either (\_ -> defaultPort) id >>>
  pure

main :: forall e. Eff (console :: CONSOLE, fs :: FS, exception :: EXCEPTION | e) Unit
main =
  logShow =<< getPort
```  

### Records

Skipping the import declarations, the first new piece of syntax is `newtype Port = Port { port :: Int }`.  This newtype has an underlying record type, which is an essential building block in PureScript that mimics JavaScript objects.  This fact makes it my choice for representing our JSON string `{"port": 8888}` in `config.json`.  You can read more about records in [Purescript by Example](https://leanpub.com/purescript/read#leanpub-auto-functions-and-records).  Also,  see [Tutorial 2](https://github.com/adkelley/javascript-to-purescript/tree/master/tut02) for another example of a `newtype` and its class instances.


On the next line, we create a class instance of `show` for `Port`, which declares how to log the port number to the console. Next up is our `defaultPort`, for cases where there's an exception during one of the error tests.  Then comes `parsePort`, which has the responsibility of parsing the JSON string from `config.json` to our port object.  There's a lot to unpack in this function, so check to ensure you have a full cup of coffee or tea before proceeding.

The function `parseJSON` is equivalent to `JSON.parse()` in JavaScript.  It returns a value or object described by the string or a syntax error in case of an exception.  To get the object returned from `parseJSON` into an Either constructor, we use `runExcept`.  Then, wrap the return object in a `Right` with a value type of `Foreign`.  Or, in case there is an exception, wrap the syntax error in a `Left (NonEmptyList ForeignError)`.  Now let's go over these new types, `Foreign`, and `NonEmptyList ForeignError`.

Types & effects in PureScript are more granular than other FP languages, so that you better understand what sort of data you are handling.  Using our current code example, when we attempt to parse the JSON string from `config.json`, there is no guarantee that the object will be in the correct form.  PureScript exposes this fact in the type system with the type, `Foreign`.  This type denotes a JSON response or even a value returned from JavaScript code.

Now what about (NonEmptyList ForeignError)?  Well, I hope you see that familiar theme I mentioned of granularity.  The type `ForeignError` denotes foreign type errors stemming from an attempt to get a JSON response or a value returned from Javascript code.  So like `Foreign`, they are exposed directly within the type system, and because there can be multiple errors generated by an exception handler, we collect them in a nonempty list.

With `Foreign` and `ForeignError` out of the way, let's finish up `getPort`. After parsing the JSON string, when the result is a syntax error then take the `ForeignError` from the head of the nonempty list `nel`, convert it to a string, and wrap the JavaScript error in `Left`.  If parseJSON is successful, then coerce the object into a `Port` type, with the help of `unsafeFromForeign x :: Port`, and then wrap it in `Right`.

And finally there is `getPort`.  First, notice the return type signature:

`forall eff. Eff (fs :: FS, exception :: EXCEPTION | eff) Port`

It is very what side effects `getPort` creates along with the return type.  Once again, we see `(try $ readTextFile)` which will return an `Eff FS (Right String)` or, in the case of an exception, `Eff EXCEPTION (Left Error)`.  Then, use the bind operator `>>=` to take the Either construct out of the `Eff` monad, which becomes our second argument in `chain`.  After executing `chain`, we compose the result with `either` to deliver a port number. Finally,  wrap the result back in the `Eff` monad with `pure`.


## Final Points

In my [github repository]((https://github.com/adkelley/javascript-to-purescript/tree/master/tut04P2), I've created two versions of `getPort` - one that ignores any errors and returns `Port`, and the other returns Either Error Port.  You can play around with the latter by creating JSON or read file errors and view them in the console.  Also, I've added another exception handler to illustrate how to compose multiple `chain` functions together.

### Be careful - bind is different from the chain!

For example, imagine applying a bind operation to an Either construct; for instance `(Right "port: 8888") >>= parsePort`.  Bind will take "port: 8888" out of `Right` and expose the string directly to `parsePort`.  But to our detriment, we lost the context of `Left` or `Right`; namely whether there has been an error or success so far.  So how do we know whether to apply `parsePort`?  We don't, but fortunately, the compiler will likely detect this problem because the types wrapped in a `Left` or a `Right` are often different.  In contrast, with `chain` we are passing the `Either` constructor intact, so we know to restrain from function application whenever `Left Error` is passed in.


## Navigation
[<< Introduction](https://github.com/adkelley/javascript-to-purescript)[< ](https://github.com/adkelley/javascript-to-purescript/tree/master/tut03) Tutorials [ >](https://github.com/adkelley/javascript-to-purescript/tree/master/tut05)

You may find that the README for the next tutorial is under construction. But if you're an eager beaver and would like to look ahead, then most the of code samples from Brian's [videos](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) have been ported to PureScript already. But I may amend them as I write the accompanying tutorial markdown.
