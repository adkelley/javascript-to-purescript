# Use bind for composable error handling with nested Eithers
## Part 1 - Managing Native Side Effects in PureScript

![series banner](../resources/glitched-abstract.jpg)

> *Note: This is* **Tutorial 4 - Part 1** *in the series* **Make the leap from JavaScript to PureScript** *. Be sure*
> *to read the series introduction where we cover the goals & outline, and the installation,*
> *compilation, & running of PureScript. I will be publishing a new tutorial approximately*
> *once-per-week. So come back often, there is a lot more to come!*

> [<< Introduction](https://github.com/adkelley/javascript-to-purescript) [< Tutorial 3](https://github.com/adkelley/javascript-to-purescript/tree/master/tut03)

The series outline and javascript code samples were borrowed with permission from the egghead.io course [Professor Frisby Introduces Composable Functional JavaScript](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) by
[Brian Lonsdorf](https://github.com/DrBoolean) - thank you, Brian! A fundamental assumption of each tutorial is that you've watched his video before tackling the equivalent PureScript abstraction featured in this tutorial.  Brian covers the featured concepts extremely well, and I feel it's better that you understand its implementation in the comfort of JavaScript. Let me mention that if you read something that you feel could be explained better, or a code example that needs refactoring, then please let me know via a comment or send me a pull request on [Github](https://github.com/adkelley/javascript-to-purescript/tree/master/tut04P1).

## Introduction

In my previous tutorial, I introduced the `Either` functor and showed how to use it to express a series of computations that may or may not succeed.  Now we’re going to practice it by demonstrating how to chain nested multiple `Either` functors using `bind`.  In Part 1 of this tutorial, I take a detour to introduce handling of native side effects in PureScript.  You will need this knowledge to understand what I am doing in Part 2.

In Part 2, I will follow Brian's [lesson](https://egghead.io/lessons/javascript-composable-error-handling-with-either) on handling nested `Either`s and show you how to take a function that uses `try/catch` and refactor it into a single composed expression using `Either`. Finally, I will introduce the `bind` function (typically called `chain` in JavaScript functional programming) to deal with nested `Either`s resulting from two try/catch calls.

## Managing native side effects

You may be asking yourself, "what is a side effect and furthermore what is a 'native' side effect?".  A function or expression creates a side effect by modifying some state outside its scope, or it has an observable interaction with its calling functions or the outside world.  Now if you generate a side effect using the runtime system, e.g., console IO, random number generation, file IO, etc., then it is also a native side effect.  An example of 'non-native' side effect is the error I represented by the `Left` constructor in my [previous tutorial](https://github.com/adkelley/javascript-to-purescript/tree/master/tut03) whenever a color was missing from the `masterColors` list.  For a complete explanation of the distinction between native and non-native side effects, please see [PureScript by Example](https://leanpub.com/purescript/read#leanpub-auto-native-effects).

PureScript has a well-typed and granular API for dealing with side-effects.  It is the `Eff` monad, and all operations with native side-effects get executed inside this monad.   In fact; I used `Eff` in previous tutorials to log the results of my code to the console! Now don't worry if you have not encountered monads yet.  I won't belabor this tutorial with an attempt to define them or create yet another “a monad is like a burrito” analogy.  'All in good time' as the saying goes.  If you are like me, I learn better by working through concrete examples of an abstraction first.  Then, after I’ve developed a good intuition about it,  I will go back and learn what it is in greater detail.  Finally, please note that I have shortened `native side effects` to `effects` for the remainder of this tutorial.

## Code Example 1

Brian’s JavaScript [code examples]((https://egghead.io/lessons/javascript-composable-error-handling-with-either)) involve reading a port number from a JSON file.  So I thought I would create two code examples with a variation on that theme.  In my first example, I generate a random port number and log it to the console.  Consequently, it creates two effects, RANDOM & CONSOLE, and I declare them using the type system.  When you run this example, you should see a port number between 2500 and 7500.

```haskell
module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Eff.Random (RANDOM, randomInt)

type PortRange = { min :: Int, max :: Int }

validPorts :: PortRange
validPorts = { min: 2500,  max: 7500 }

main :: Eff (console :: CONSOLE, random :: RANDOM) Unit
main = do
  log "Use chain for composable error handling with nested Eithers - Part 1"
  portNumber <- randomInt (validPorts.min) (validPorts.max)
  log $ "Our random port number is: " <> show portNumber
```

I import the `Control.Monad.Eff` and `Control.Monad.Eff.Console` modules for logging my results to the console.  I also import the `Control.Monad.Eff.Random` for generating random integers using `randomInt`.  For this to compile, I added both the `purescript-console` and `purescript-random` dependencies to my `bower.json` file.

Look at the type declaration of `main`.  It signifies that it will run a computation with two effects; 1) logging to the `CONSOLE` and 2) generating `RANDOM` numbers, yielding a value of type `Unit`.  Thanks to the granularity of `EFF`, there is good clarity, meaning that the reader of my program can trust that I am creating these two effects, only.

Alternatively, you’ll most often see a type declaration like the following:

```haskell
main :: forall eff. Eff (console :: CONSOLE, random :: RANDOM | eff) Unit
```

It tells you that the module `main` is an effectful computation, which runs in any environment that supports RANDOM number generation and CONSOLE IO.  All good so far, but adding ` | eff` means that `main` will also support other side effects, yielding a value of type Unit.

Now, since we're writing strings to the console, the astute reader may be asking, why doesn’t `main` return `String` instead of `Unit`?  Well again, `main` is a computation that has effects and thus you cannot emulate them by pure functions.  So instead, `Unit` (i.e., nothing) is returned to indicate that `main` has terminated correctly.  Continuing,  `main` creates a random integer between 2500 and 7500 using the function `randomInt` and assigns it to the variable `portNumber`.  Finally, I print the port number to the console using our old and trusted friend ‘log’.

I introduced a few new pieces of PureScript syntax in this example that I'll go over.  Working our way down, I'm using an example of PureScript’s record type to declare the range of valid ports `type PortRange = { min :: Int, max :: Int }`.  I could've used a tuple, but I feel record syntax is easier for storing and accessing related values, mimicking JavaScript-style objects.  

In `main`, the keyword `do` indicates a block code that uses do notation.  I'm using do notation to sequence my console logging operations, but also there is the operator `<-` in this sequence.  It acts as a single assignment operation in my `do` constructor.  Finally ‘<>’ is the operator alias for appending semigroups (strings are one example), and the `show` function converts types such as `Int` into a human readable `String` representation.   Now, let's move to the next example to introduce JavaScript’s runtime exceptions.

## Code Example 2

In the code example below, I am adding a new effect to our arsenal by introducing JavaScript runtime exception handling using `throwException` and `catchException`. These functions work exactly like their JavaScript counterparts (`throw` and `catch`) giving the ability to throw and catch user-defined exceptions.  

```haskell
module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Eff.Exception (EXCEPTION, Error, catchException, error, message, throwException)
import Control.Monad.Eff.Random (RANDOM, randomInt)

type PortRange = { min :: Int, max :: Int }

validPorts :: PortRange
validPorts = { min: 2500,  max: 7500 }

isInvalidPort :: Int -> Boolean
isInvalidPort portNumber =
  (portNumber < validPorts.min || portNumber > validPorts.max)

throwWhenBadPort ::  Int -> forall eff. Eff (err :: EXCEPTION | eff) Unit
throwWhenBadPort portNumber =
  when (isInvalidPort portNumber) $ throwException errorMessage
  where
    errorMessage = error $ "Error: expected a port number between " <>
                              show validPorts.min <> " and " <> show validPorts.max


catchWhenBadPort :: Int -> forall eff. Eff (console :: CONSOLE | eff) Unit
catchWhenBadPort portNumber =
  catchException printException $ throwWhenBadPort portNumber
  where
    printException e = log $ message e

main :: Eff (console :: CONSOLE, random :: RANDOM, err :: EXCEPTION) Unit
main = do
  log "Use chain for composable error handling with nested Eithers - Part 1"
  -- Create a 50% chance of generating a invalid port number
  portNumber <- randomInt (validPorts.min - 2500) (validPorts.max + 2500)
  log $ "Our random port number is: " <> show portNumber

  -- Try commenting out catchWhenBadPort and uncommenting throwWhenBadPort
  -- to see throwException in action
  catchWhenBadPort portNumber
  -- throwWhenBadPort portNumber
```

I import the `Control.Monad.Eff.Exception` module, tapping on four functions - `throwException`, catchException, error, and message.  My first function `inValidPort`, determines whether the portNumber we’ve supplied is within the range of `validPorts`.  When it is an invalid port number, `throwWhenBadPart` will throw an exception.  To help grok this example, take a look at the type signatures of  `throwException` and `catchException`:

```haskell
throwException :: forall a eff. Error -> Eff (exception :: EXCEPTION | eff) a
```

`Error` is the type of JavaScript errors, and whenever the port number is invalid, I trigger a JavaScript error using the function `error :: String -> Error` in the example above.

`catchException` is similar:

```haskell
catchException :: forall a eff. (Error -> Eff eff a) -> Eff (exception :: EXCEPTION | eff) a -> Eff eff a
```

Notice that the input to `catchException` is simply the output from `throwException` - makes sense! Then I'm telling catchException to generate a `CONSOLE` effect by using `printException` to log the error message from `catchWhenBadPort` to the console.

Moving onto `main`, you will notice that I’ve increased the port number range returned from `randomInt` so that there’s a 50% chance of throwing and catching an exception.  Also, try experimenting with commenting out `catchWhenBadPort` and calling `throwWhenBadPort` directly to see what happens when you throw an exception in PureScript.  If you're careful, then no functional programmers will be harmed during your experiments.

## Final Thoughts

Congratulations!  With the topic of side effects out of the way, you just cleared a major hurdle toward functional programming in PureScript.  It was enough material to warrant a tutorial, and by giving it this level of attention, I hope you will be comfortable in using them in Part 2.  That’s all and stay tuned for Part 2 where we’ll add the file system to our tool chest of effects and wrestle with handling nested Either expressions.  Stay tuned!

## Navigation
[<< Introduction](https://github.com/adkelley/javascript-to-purescript)[< ](https://github.com/adkelley/javascript-to-purescript/tree/master/tut03) Tutorials [ >](https://github.com/adkelley/javascript-to-purescript/tree/master/tut05)

You may find that the README for the next tutorial is under construction. But if you're an eager beaver and would like to look ahead, then most the of code samples from Brian's [videos](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) have been ported to PureScript already. But I may amend them as I write the accompanying tutorial markdown.
