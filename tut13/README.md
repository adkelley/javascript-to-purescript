# Use Task for Asynchronous Actions

![Series banner](../resources/glitched-abstract.jpg)

> *This is* **Tutorial 13** *in the series* **Make the leap from JavaScript to PureScript**. Be sure
> *to read the series introduction where I cover the goals & outline, and the installation,*
> *compilation, & running of PureScript. I will be publishing a new tutorial approximately*
> *once-per-week. So come back often, there is a lot more to come!*

> [<< Introduction](https://github.com/adkelley/javascript-to-purescript) [< Tutorial 12](https://github.com/adkelley/javascript-to-purescript/tree/master/tut12)


  ## Introduction
Welcome to Tutorial 13 in the series **Make the leap from Javascript to PureScript**.  I hope you're enjoying it thus far.  If you're new to this series, then be sure to read the series [Introduction](https://github.com/adkelley/javascript-to-purescript) to learn how to install and run PureScript.  The series outline and javascript code samples were borrowed with permission from the egghead.io course [Professor Frisby Introduces Composable Functional JavaScript](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) by
[Brian Lonsdorf](https://github.com/DrBoolean) - thank you, Brian! A fundamental assumption of each tutorial is that you've watched his [video](https://egghead.io/lessons/javascript-using-task-for-asynchronous-actions)  before tackling the equivalent PureScript abstraction featured in this tutorial.  Brian covers the featured concepts exceptionally well, and I feel it's better that you understand his implementation first, in the comfort of JavaScript.  

In this tutorial, we are going to refactor our structure `Task` from [Tutorial 12](https://github.com/adkelley/javascript-to-purescript/tree/master/tut12) so that it mimics a standard node callback style based workflow - minus the callbacks! If you recall, I mentioned we could implement [FolkTale] (http://folktalegithubio.readthedocs.io/en/latest/api/data/task/index.html?highlight=task)'s `Task` using two approaches.  The first is Continuation Passing Style (CPS) which we covered in the last tutorial. The second is using asynchronous computation, which we'll utilize in this tutorial.   I should also mention again that, unlike [Elm](http://package.elm-lang.org/packages/elm-lang/core/latest/Task) or FolkTale, there is no `Task` package or structure in PureScript.  So I implemented my own *semi-version* of the API using the functionality that is available in PureScript. 

In my [Tutorial 13 repository](https://github.com/adkelley/javascript-to-purescript/tree/master/tut13), you'll find that, in addition to the new examples from Brian's [video](https://egghead.io/lessons/javascript-using-task-for-asynchronous-actions), I've rewritten the examples from Tutorial 12 to utilize `Aff`, instead of the continuation monad `Cont`.  

This tutorial covers the high-level aspects of implementing the examples from Brian's videos (Tutorial 12 & 13) in PureScript.  However, I won't get into the details of how I implemented the Task API.  This way, if you're not interested or you’re still a beginner at PureScript, then you won’t feel annoyed or overwhelmed by some of the dense type signatures that I needed to make it work.  But you should be aware that  [purescript-aff](https://pursuit.purescript.org/search?q=purescript-aff) is the library that I and everyone else use to implement asynchronous computations in PureScript.  Let's get started by taking a step back to discuss how to write asynchronous programs in PureScript.

## Asynchronous programming in PureScript using Aff
Here, `Aff` stands for 'asynchronous effects' and the library [purescript-aff](https://pursuit.purescript.org/packages/purescript-aff/4.1.1) allows us to write our programs as if we were writing synchronous code with effects.  However, behind the scenes, our program is operating asynchronously without any callbacks.  Moreover, error handling is baked in, so we can use the functions from `Task` to deal with it the way we want.  If you've looked at the `purescript-aff` library already and wondered how to put it into action, then this tutorial is for you! 

In [Tutorial 4 - Part 1](https://github.com/adkelley/javascript-to-purescript/tree/master/tut04P1), I introduced the topic of *side effects*.  As a review, a function or expression creates a side effect, such as logging to console, by modifying some state outside its scope, or it has an observable interaction with its calling functions or the outside world.   Now, so far, we have been using the `Eff` monad to manage and contain these side effects.  But when we're programming asynchronously, when some asynchronous part of our program creates a side-effect, then the equivalent to `Eff` that we use is `Aff`.

Anything run under the `Aff eff a`  monad is an asynchronous computation with effects `eff`.  The computation may error with an exception, or produce a type `a`.

##  Task API - First glance
Let's first remind ourselves that a Task, when implemented asynchronously, represents asynchronous effects that may fail.  It's useful for stuff like reading and writing a file, hitting an API endpoint, etc.  In my [GitHub repository](https://github.com/adkelley/javascript-to-purescript/tree/master/tut13), I suggest the first file you look at is `Control.Monad.Task` which is my Task API.   In that module, you'll find the signature for the `Task`  type constructor:

```haskell
type Task e a = (Aff e) a
```
Wow! `Task` is merely a type synonym for the `Aff`` monad!  I told you - there's no `Task` API in PureScript, but it is easily modeled with `Aff`.  

## Tutorial 12 Revisited
Now, taking the examples from [Tutorial 12](https://github.com/adkelley/javascript-to-purescript/tree/master/tut12), it's easy to match the functionality of `Folktale.Task`.  Again, these are the asynchronous `Aff`` alternative to using the continuation monad `Cont` we covered in the last tutorial and you'll find this code in [Tut12Aff.purs](https://github.com/adkelley/javascript-to-purescript/blob/master/tut13/src/Tut12Aff.purs)  

``` haskell
-- | TutAff.purs
tut12Res :: ∀ eff. Task (console :: CONSOLE | eff) Unit
tut12Res =
  taskOf "good task"
  # fork (\e → log $ "err " <> e) (\x → log $ "success " <> show x)

tut12Rej :: ∀ eff. Task (console :: CONSOLE | eff) Unit
tut12Rej =
  taskRejected "bad task"
  # fork (\e -> log $ "err " <> show e) (\x -> log $ "success " <> x)

-- | Main.purs
main 
     :: ∀ e
       . Eff   ∀ e. Eff (console :: CONSOLE, exception :: EXCEPTION | e) Unit
main = do
  log "\nTut12 - Task.of example"
  void $ launchAff tut12Res
  log "\nTut12 - Task.rejected example"
  void $ launchAff tut12Rej
```
Hopefully, now that you're familiar with our Task constructor, the code snippet above is not so scary.  First, `tut12Res` creates a task of String "good task",  and because `taskOf` always returns a successful computation,  `fork`  will return the code given in the right parenthesis (i.e., log $ "success" ...).  The function `tut12Rej`, does the opposite by rejecting the task and throwing an error.  So, we handle the error by "forking left", logging "err bad task" to the console.  

Now, the functions, `tut12Res` and `tut12Rej` merely return a `Task`. Thus their computations aren't performed until we run them using the function `launchAff` given in the `main` module.  So what you're seeing is a mix of synchronous and asynchronous computations combined in the `main` do block.  For example, `log "\nTut12 - Task.rejected example"` is performed synchronously, while `\x →  log $ "success " <> show x` is performed asynchronously.  What I love about `purescript-aff` is that you feel like you're writing synchronous code, and relieved from the task of writing tedious callbacks in JavaScript.

I've also rewritten "launchMissles" and "rejectMissles" from the Tutorial12 repository to use async computation, so check out [Tut12Aff](https://github.com/adkelley/javascript-to-purescript/blob/master/tut13/src/Tut12Aff.purs  to see those examples.  Note, they're using the concepts that are covered in the Tutorial13 example below, so let's move on and explore a couple of new type signatures.

##  Task API - Second glance.
Next, let’s look at the type signature of `TaskE`.  We'll use it whenever we create a `newTask`.  

```haskell
type TaskE x e a = ExceptT x (Aff e) a
```

Yes, the type alias for `TaskE` is a little dense, so first let’s understand what is `ExceptT x`.  Without going down into the Monad rabbit hole, you can think of `ExceptT` as a wrapper which adds exceptions `x` to other monads.  So the `E` at the end of `Task` makes this distinction.  In our case, the other monad in this structure is `(Aff e) `, and we know, from the discussion above, that exceptions are an effect from Aff.  Fun fact - the `T` in `ExceptT`  stands for *transformation* because we are transforming our `(Aff e) ` monad into one that can handle both exceptions and effects. 

We need the ability manually throw an exception, particularly in `taskRejected`, and act on them.  When we `runExceptT` (see `toAff` in [Task.purs](https://github.com/adkelley/javascript-to-purescript/blob/master/tut13/src/Control/Monad/Task.purs) ) , our `TaskE` structure is transformed into `Aff e (Either x a)`.  This sets us up to execute our `rej` or `res` functions (see explanation below) , depending on a failure or successful computation, respectively.  Whew!

This is as far as I want to go in explaining my Task API.  Because assuming you watched Brian's [video](https://egghead.io/lessons/javascript-using-task-for-asynchronous-actions) then you don’t need any further information to implement his read/write file example.  But if you're farther along in your PureScript adventures then feel free to study the code.  Writing it certainly helped with my understanding in implementing asynchronous computations.

## File operations using TaskE
If you have looked at Brian's [video](https://egghead.io/lessons/javascript-using-task-for-asynchronous-actions) (didn't I say you should watch and understand Brian's video first)  you'll see that the main example is reading a configuration file and writing out a new port number using `Task` from Folktale.js  We're going to do the same here in PureScript.

```haskell
-- | Tut13.purs
readFile_
  :: ∀ e
   . Encoding → String
   → TaskE String (fs :: FS, console :: CONSOLE | e) String
readFile_ enc filePath =
  newTask $
  \cb -> do
    Console.log ("\nReading File: " <> filePath)
    result ← try $ readTextFile enc filePath
    cb $ either (\e → rej $ show e) (\success → res success) result
    pure $ nonCanceler

-- | Main.purs
main 
  :: ∀ e
   . Eff   ∀ e. Eff (console :: CONSOLE, exception :: EXCEPTION | e) Unit
main = do
  log "\nTut13 - Async Read/Write file example"
  void $ launchAff $
    fork (\e → AC.log $ "error: " <> e)
         (\x → AC.log $ "success: " <> x)
          app
```
We covered reading a file, including regular expressions back in TutorialXX.  So hopefully, some parts look familiar to you.  The new pieces are `newTask` and the lambda function `cb`  (denoted `\cb ->`), which represents our callback.   There's also `nonCanceler` and the `rej ` & `res` functions, which I'll cover in a bit.  

First, note that the entire callback `cb` and `pure $ nonCanceler` are wrapped in `newTask`.  After logging a debugging message to the console, the callback attempts to read the file using [try] (https://pursuit.purescript.org/packages/purescript-exceptions/4.0.0/docs/Effect.Exception#v:try).  If successful, then `try` will return the text from the file and wrap it in a `Right` constructor.  Otherwise, if there's an exception, then wrap the error in a `Left` constructor.  

The `either` function will take the result, and if it's a `Left` constructor (i.e., the read failed) then the computation in the first argument is executed, which passes the error to the `rej` function.  Otherwise, the computation in `either`'s second argument (i.e., the `res` function) is executed.

What's left in this signature is the `Canceler e`, which tells `makeAff` how to clean up after the async computation.  For example, if an async process is killed and an async action is pending, then the canceler is called to clean up.  In our case, we don't have any elaborate async processes so, as you'll see below,  we can provide newTask with the `NonCanceler`.  Which, as you may suspect, provides `makeAff` with a canceler that doesn't cancel anything.

As Brian mentions, we don't want to log success somewhere buried deep within our function.  So I've delegated the honors to our `main` module, by importing `fork` from `Control.Monad.Task`.  One thing to mention is that, in my fork function, I'm using `Console.Monad.Aff.Console.log` to log failure or success to the console because it's being performed asynchronously within the `Aff` monad.

### Summary


  

## Resources
* [Principled, Painless Asynchronous Programming in PureScript](https://github.com/degoes-consulting/lambdaconf-2015/blob/master/speakers/jdegoes/async-purescript/presentation.md) - John Degoes
* [Async Programming](https://www.youtube.com/watch?v=dbM72ap30TE) - Nate Faubion, LA PureScript Meetup 12/95/17


## Navigation
[<--](https://github.com/adkelley/javascript-to-purescript/tree/master/tut12) Tutorials [-->](https://github.com/adkelley/javascript-to-purescript/tree/master/tut14)

You may find that the README for the next tutorial is under construction. But if you're an eager beaver and would like to look ahead, then all the of code samples from Brian's [videos](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) have been ported to PureScript already. But I may amend them as I write the accompanying tutorial markdown.  
