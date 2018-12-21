# Use Task for Asynchronous Actions

![Series banner](../resources/glitched-abstract.jpg)

> *This is* **Tutorial 13** *in the series* **Make the leap from JavaScript to PureScript**. Be sure
> *to read the series introduction where I cover the goals & outline, and the installation,*
> *compilation, & running of PureScript. I will be publishing a new tutorial approximately*
> *once-per-week. So come back often, there is a lot more to come!*
>
> [Index](https://github.com/adkelley/javascript-to-purescript/tree/master/index.md) | [<< Introduction](https://github.com/adkelley/javascript-to-purescript) [< Tutorial 12](https://github.com/adkelley/javascript-to-purescript/tree/master/tut12) | [Tutorial 14](https://github.com/adkelley/javascript-to-purescript/tree/master/tut14) [Tutorial 19 >>](https://github.com/adkelley/javascript-to-purescript/tree/master/tut19)


## Introduction
Welcome to Tutorial 13 in the series **Make the leap from Javascript to PureScript**.  I hope you're enjoying it thus far.  If you're new to this series, then be sure to read the [Introduction](https://github.com/adkelley/javascript-to-purescript) to learn how to install and run PureScript.  The series outline and javascript code samples were borrowed with permission from the egghead.io course [Professor Frisby Introduces Composable Functional JavaScript](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) by
[Brian Lonsdorf](https://github.com/DrBoolean) - thank you, Brian! A fundamental assumption of each tutorial is that you've watched his [video](https://egghead.io/lessons/javascript-using-task-for-asynchronous-actions)  before tackling the equivalent PureScript abstraction featured in this tutorial.  Brian covers the featured concepts exceptionally well, and I feel it's better that you understand his implementation first, in the comfort of JavaScript.  

In this tutorial, we are going to refactor our structure `Task` from [Tutorial 12](https://github.com/adkelley/javascript-to-purescript/tree/master/tut12) so that it mimics a standard node callback style based workflow - minus the nested callbacks! If you recall, I mentioned we could implement [FolkTale.js](http://folktalegithubio.readthedocs.io/en/latest/api/data/task/index.html?highlight=task) `Task` using two approaches.  The first is Continuation Passing Style (CPS), which we covered in the last tutorial. The second is using asynchronous actions, which we'll utilize in this tutorial.   I should also mention again that, unlike [Elm](http://package.elm-lang.org/packages/elm-lang/core/latest/Task) or FolkTale.js, there is no `Task` package or structure in PureScript.  So I implemented my own *semi-version* of the API using the functionality that is readily available in PureScript.

This tutorial covers the high-level aspects of implementing the examples from Brian's videos from Tutorial 12 & 13 in PureScript, which you'll find in my [tut13 repository](https://github.com/adkelley/javascript-to-purescript/tree/master/tut13).  However, I won't get too deep into the details of how I implemented the Task API.  This way, if you're not interested or you’re still a beginner at PureScript, then you won’t feel annoyed or overwhelmed by some of the dense type signatures that I needed to make it work.  Be aware that  [purescript-aff](https://pursuit.purescript.org/search?q=purescript-aff) is the library that we use to implement asynchronous computations in PureScript.  Let's get started by taking a step back to discuss how to write asynchronous computations in PureScript. For more information on `purescript-aff,` be sure to have a look at the references that I've listed at the end of this tutorial.

## Asynchronous programming using Aff
Asynchronous programming in PureScript is performed using the `Aff` monad.  Here, `Aff` stands for “asynchronous effects” and `purescript-aff` allows us to write our programs as if we were writing synchronous code with effects.  However, behind the scenes, our program is operating asynchronously without any nested callbacks, similar to promises in JavaScript.  Moreover, error handling is baked in, so we can use the functions from `Task` (or any error handling function) to deal with them the way we want.  If you've looked at the `purescript-aff` library and wondered how to put it into action, then this tutorial is for you!

In [Tutorial 4 - Part 1](https://github.com/adkelley/javascript-to-purescript/tree/master/tut04P1), I introduced the topic of *side effects*.  A function or expression creates a side effect, such as logging to the console, by modifying some state outside its scope, or it has an observable interaction with its calling functions or the outside world.   So far, we have been using the `Eff` monad to manage our side effects. But when we're programming asynchronously, then we use `Aff` instead of `Eff`.  So anything run under the `Aff eff a`  monad is an asynchronous computation with effects `eff`.  The computation may error with an exception, or produce a type `a`.

##  Task API - First type constructor
Let's first remind ourselves that a Task, when implemented asynchronously, represents asynchronous effects that may fail.  It's useful for stuff like reading and writing a file or hitting an API endpoint.  However, before we delve into our first type signature, I want to mention that Ryan Rempel's talk on [Elm in PureScript](https://www.youtube.com/watch?v=O_kWwaghZ9U) inspired me for the `Task` and `TaskE` structures. It helped to move my code examples along.  In my [GitHub repository](https://github.com/adkelley/javascript-to-purescript/tree/master/tut13), I suggest that you first look at my Task API `Control.Monad.Task`. In that module, you'll find the signature for the `Task`  type constructor:

```haskell
-- | Task.purs (excerpt)

type Task a = Aff a
```
Here the type constructor `Task a` represents an asynchronous computation with effects that may error or produce a result of type `a`.  From the description above, recognize that`Task` is just a type synonym for the `Aff` monad, and therefore I could've represented it as such.

## Tutorial 12 Revisited
Now, taking the examples from [Tutorial 12](https://github.com/adkelley/javascript-to-purescript/tree/master/tut12), it's easy to match the functionality of `Folktale.Task`.  Remember, these are the asynchronous `Aff` alternatives to using the continuation monad `Cont` we covered in the last tutorial.  You'll find this code in [Tut12Aff.purs](https://github.com/adkelley/javascript-to-purescript/blob/master/tut13/src/Tut12Aff.purs)

``` haskell
-- | Tut12Aff.purs (excerpt)

tut12Res :: Task Unit
tut12Res =
  taskOf "good task"
  # fork (\e → log $ "err " <> e) (\x → log $ "success " <> show x)

tut12Rej :: Task Unit
tut12Rej =
  taskRejected "bad task"
  # fork (\e -> log $ "err " <> show e) (\x -> log $ "success " <> x)

-- | Main.purs (excerpt)
main Effect Unit
main = do
  log "\nTut12 - Task.of example"
  void $ launchAff tut12Res
  log "\nTut12 - Task.rejected example"
  void $ launchAff tut12Rej
```
Hopefully, now that you're familiar with our `Task` type constructor, the code snippet above is not so scary.  First, let's look at the type signature for `tut12Res`.  It states the for all effects `eff`, we return an asynchronous `Task` that logs our result to the console (and any other effect); along with a type `Unit` which represents no computational content.  The function `tut12Res` creates a task of String "good task",  and because `taskOf` always returns a successful computation, `fork` returns the "success" code given in its right argument.  The function `tut12Rej`, does the opposite by rejecting the task and throwing an error.  So, we handle the error by executing the first argument; logging "err bad task" to the console.

When we run the function `launchAff`, shown in the `main` module, then that is the time we execute our asynchronous tasks created by `tut12Res` and `tut12Rej`.  In the `main` do block, we see a mix of synchronous and asynchronous computations combined.  For example, `log "\nTut12 - Task.rejected example"` is performed synchronously, while `\x →  log $ "success " <> show x` in `Tut12Aff.purs` is performed asynchronously.  What I love about `purescript-aff` is that you feel like you're writing synchronous code, and relieved from writing tedious callbacks in JavaScript.

I've also rewritten "launchMissiles" and "rejectMissiles" from the Tutorial12 repository to use async computation, so check out [Tut12Aff](https://github.com/adkelley/javascript-to-purescript/blob/master/tut13/src/Tut12Aff.purs)  to see those examples.  They're using concepts covered in the example `Tut13.purs` (see  below).  So let's move on and explore the other important type signature from `Task.purs`.

##  Task API - Second type constructor

```haskell
-- | Task.purs (excerpt) 

type TaskE x a = ExceptT x (Aff a)
```

Don't be confused by the difference between `Task` and `TaskE`,  rather bear with me for a moment.  The type alias for `TaskE` is a little dense, so first let’s understand what is `ExceptT x`.  Without going down into the monad rabbit hole, you can think of `ExceptT` as a wrapper which adds exceptions `x` to other monads.  So the `E` at the end of the name `TaskE` makes this distinction.  In our case, the other monad in this structure is `Task a`.  Also, as a reminder, `Task a` is a type synonym for `Aff a`.

So by creating `TaskE`, I am adding the ability to throw an exception in the `Task` monad manually.  I need this capability to implement `taskRejected` correctly.  One other benefit is that exceptions `x` can be any type (e.g., `String`), and no longer limited to the `Error` type exclusively.  When we `runExceptT` (see `toAff` in [Task.purs](https://github.com/adkelley/javascript-to-purescript/blob/master/tut13/src/Control/Monad/Task.purs) ) , our `TaskE` structure is transformed into `Aff (Either x a)`.  This transformation sets us up to execute our `rej` or `res` functions (see explanation below), depending on failure or a successful computation, respectively.  Whew!

This explanation is as far as I want to go in delving into my Task API.  Because assuming you watched Brian's [video](https://egghead.io/lessons/javascript-using-task-for-asynchronous-actions), then you don’t need anything further to implement his read/write file example.  I've modeled my Task API to resemble the Folktale implementation of `Task` closely. However, if you're farther along in your PureScript adventures then feel free to study the code.  Writing it certainly helped with my understanding in implementing asynchronous computations.

## File operations using TaskE
The primary example in Brian's [video](https://egghead.io/lessons/javascript-using-task-for-asynchronous-actions) is reading a configuration file and writing out a new port number using `Task` from Folktale.js.  We're going to do the same in this example using PureScript.

```haskell
-- | Tut13.purs (excerpt)
readFile_
  :: Encoding → String
   → TaskE String String
readFile_ enc filePath =
  newTask $
  \cb -> do
    Console.log ("\nReading File: " <> filePath)
    result ← try $ readTextFile enc filePath
    cb $ either (\err → rej $ show err) (\success → res success) result
    pure $ nonCanceler

app :: TaskE String Unit
app = do
  readFile_ UTF8 pathToFile
  # map newContents
  # chain (\x → writeFile_ UTF8 pathToFile x)

-- | Main.purs (excerpt)
main :: Effect Unit
main = do
  log "\nTut13 - Async Read/Write file example"
  void $ launchAff $
    fork (\e → AC.log $ "error: " <> e)
         (\_ → AC.log $ "success")
         app
```
We covered reading a file, including regular expressions, back in [Tutorial4](https://github.com/adkelley/javascript-to-purescript/tree/master/tut04P2).  So hopefully, some parts look familiar to you.  However, let's go over the final argument in the type signature for `readFile_`. Return a `TaskE` that is parameterized by an exception of type `String`, and a successful result of type `String` (i.e., the text from the file). The new pieces are `newTask` and the lambda function `cb`  (denoted `\cb -> ...`), which represents our callback.   There's also `nonCanceler` and the `rej ` & `res` functions, which I'll cover in a bit.  

First, note that the entire callback `cb` and `pure $ nonCanceler` are wrapped in a `newTask`.  After logging a debugging message to the console, the callback attempts to read the file using [try](https://pursuit.purescript.org/packages/purescript-exceptions/4.0.0/docs/Effect.Exception#v:try).  If successful, then `try` returns the text from the file, wrapped it in a `Right` constructor.  Otherwise, if there's an exception, then it wraps the `Error` in a `Left` constructor.

The `either` function takes the result, and if it's a `Left` constructor (i.e., the read file failed) then the computation in the first argument is executed.  In this case, it turns `Error` into a `String` using `show` and finally passes the error to the `rej` function.  Otherwise, execute the computation in `either`'s second argument, passing the file's text to the `res` function.

What's left about the `newTask` signature to discuss is the `Canceler`, which tells the function how to clean up after the async computation.  For example, if an asynchronous process is killed and an asynchronous action is pending, then a canceler is called to clean up.  In our case, we don't have any elaborate asynchronous processes, so we provide newTask with the `nonCanceler` function.  As you may suspect, this function provides `newTask` with a canceler that doesn't cancel anything.  Behind the scenes, `newTask` is just a synonym for [makeaff](https://pursuit.purescript.org/search?q=makeAff) from the `purescript-aff` library.  However, I also compose `makeAff` with the `ExceptT` monad for the reasons I explained above.

The function `app` mimics the sequence of actions from Brian's video.  For the sake of brevity, I've left out `newContents` and `writeFile_`, so be sure to check out my [repository](https://github.com/adkelley/javascript-to-purescript/tree/master/tut13) for the full listing.  I should mention, that we don't need `chain` because there's an equivalent in PureScript called [bind](https://pursuit.purescript.org/packages/purescript-prelude/4.0.0/docs/Control.Bind#t:Bind).  We'll cover it when we get into monads later in the series.  However, in the meantime, I decided to add `chain` to help you follow along with Brian's JavaScript example.  

As Brian mentions, we don't want to log success somewhere buried deep within our function.  So I've delegated the honors to our `main` module, by importing `fork` from `Control.Monad.Task`.  One thing to mention is, in my fork function, I'm using `Effect.Class.Console.log` to log a failure or success to the console because it's being performed asynchronously within the `Aff` monad.

### Summary
In this tutorial and Tutorial12, we modeled the Task API from Folktale.js in PureScript using asynchronous actions and the continuation passing style respectively.  In all honesty, given all the functionality that is present already in `purescript-aff``, it's debatable whether a Task API is necessary.  However, for me, it was certainly a good exercise in asynchronous programming, and I hope it is for you.  Finally, if you have any questions about some of the functions in [Task.purs](https://github.com/adkelley/javascript-to-purescript/blob/master/tut13/src/Control/Monad/Task.purs)  then don’t hesitate to ask by leaving a comment below.

Once again, whether or not you’re finding these tutorials helpful in making the leap from JavaScript to PureScript then give me a clap, drop me a comment, or post a tweet. My twitter handle is @adkelley. I believe any feedback is good feedback and helpful toward making these tutorials better in the future. That’s all for this blog post. Till next time, when I introduce the exciting topic of Functors.

## Resources
* [Principled, Painless Asynchronous Programming in PureScript](https://github.com/degoes-consulting/lambdaconf-2015/blob/master/speakers/jdegoes/async-purescript/presentation.md) - John Degoes
* [Async Programming in PureScript](https://www.youtube.com/watch?v=dbM72ap30TE) - Nate Faubion, LA PureScript Meetup 12/95/17


## Navigation
[<--](https://github.com/adkelley/javascript-to-purescript/tree/master/tut12) Tutorials [-->](https://github.com/adkelley/javascript-to-purescript/tree/master/tut14)

You may find that the README for the next tutorial is under construction. But if you're an eager beaver and would like to look ahead, then all the of code samples from Brian's [videos](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) have been ported to PureScript already. But I may amend them as I write the accompanying tutorial markdown.
