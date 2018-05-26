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

In this tutorial, we are going to refactor our structure `Task` from [Tutorial 12](https://github.com/adkelley/javascript-to-purescript/tree/master/tut12) so that it mimics a standard node callback style based workflow - minus the callbacks! If you recall, I mentioned we could implement [FolkTale] (http://folktalegithubio.readthedocs.io/en/latest/api/data/task/index.html?highlight=task)'s `Task` using two approaches.  The first is Continuation Passing Style (CPS) which we covered in the last tutorial. The second is using asynchronous computation, which we'll utilize in this tutorial.   I should also mention again that, unlike [Elm](http://package.elm-lang.org/packages/elm-lang/core/latest/Task) or FolkTale, there is no `Task` package or structure in PureScript.  So I implemented my own using all of the functionality is available in PureScript already.  Instead, we piece it together into an abstraction; and that’s what I've done here.

As you've probably noticed already, **I've decided to break this tutorial into two parts**.  This part (Part 1) covers the high-level aspects of implementing the examples from Brian's videos (Tutorial 12 & 13) in PureScript.  However, I won't get into the details of how I implemented the Task API.  This way, if you're not interested or you’re still a beginner at PureScript, then you won’t feel annoyed or overwhelmed by some of the dense type signatures that I needed to make it work.  But you should be aware that  [purescript-aff](https://pursuit.purescript.org/search?q=purescript-aff) is the library that I and everyone else use to implement asynchronous computations in PureScript. 

### Housekeeping
In my [Tutorial 13 repository](https://github.com/adkelley/javascript-to-purescript/tree/master/tut13), you'll find that, in addition to the new examples from Brian's [video](https://egghead.io/lessons/javascript-using-task-for-asynchronous-actions), I've rewritten the examples from Tutorial 12 to utilize `Aff`, instead of the continuation monad `Cont`.  

Let's get started by taking a step back to discuss how to write asynchronous programs in PureScript.

## Asynchronous programming in PureScript
In [Tutorial 4 - Part 1](https://github.com/adkelley/javascript-to-purescript/tree/master/tut04P1), I introduced the topic of *side effects*.  As a review, a function or expression creates a side effect, such as logging to console, by modifying some state outside its scope, or it has an observable interaction with its calling functions or the outside world.   Now, so far, we have using the `Eff` monad to manage and contain these side effects.  But what if we're programming asynchronously? If some asynchronous part of our program creates a side-effect, then what's the equivalent to `Eff`?  Well, that's the job of `Aff`, which stands for Asynchronous Side Effects - duh!  

Anything run under the `Aff eff a`  monad is an asynchronous computation with effects `eff`.  The computation may error with an exception, or produce a type `a`.
You can find `Aff` and its supporting cast of types and functions in the module [purescript-aff](https://pursuit.purescript.org/packages/purescript-aff/4.1.1).  One of the primary goals of this module is to make asynchronous programming look the same as synchronous programming with effects.  And from my examples, I believe you'll find that to be the case.

###  Task API
Let's first remind ourselves that a Task, when implemented asynchronously, represents asynchronous effects that may fail.  It's useful for stuff like reading and writing a file, hitting an API endpoint, etc.  In my [GitHub repository](), I suggest the first file you look at is `Control.Monad.Task` which is my Task API.   In that module, you'll find the signature for the `Task`  type constructor:

```haskell
type Task e a = (Aff e) a
```
First,  recognize that `Task` is merely a type synonym for the `Aff`` monad!  Again, there's no `Task` API in PureScript, but it can be easily modeled with `Aff`.  

## Tutorial 12 Revisited
Now, taking the examples from [Tutorial 12](), I show it's easy to match the functionality of `Folktale.Task` below.  Again, these are the asynchronous `Aff`` alternative to using the continuation monad `Cont` we covered in the last tutorial and you'll find this code in [Tut12Aff.purs]()  

``` haskell
tut12Res :: ∀ eff. Task (console :: CONSOLE | eff) Unit
tut12Res =
  taskOf "good task"
  # fork (\e → log $ "err " <> e) (\x → log $ "success " <> show x)

tut12Rej :: ∀ eff. Task (console :: CONSOLE | eff) Unit
tut12Rej =
  taskRejected "bad task"
  # fork (\e -> log $ "err " <> show e) (\x -> log $ "success " <> x)

main :: ∀ e. Eff   ∀ e. Eff (console :: CONSOLE, exception :: EXCEPTION | e) Unit
main = do
  log "\nTut12 - Task.of example"
  void $ launchAff tut12Res
  log "\nTut12 - Task.rejected example"
  void $ launchAff tut12Rej
```
Hopefully, now that you're familiar with our Task constructor, the code snippet above is not so scary.  First, `tut12Res` creates a task of String "good task",  and because `taskOf` always returns a successful computation, the `fork` function will return the code given in the right parenthesis (i.e., log $ "success" ...) . Now, `tut12Rej` performs the opposite, by rejecting the task and throwing an error.  So, we handle the error by "forking left" and logging "err bad task" to the console.  

Now, the functions, `tut12Res` and `tut12Rej` merely return a `Task` and so their computations aren't performed until we run them using the function `launchAff` given in the `main` module.  So what you're seeing is a mix of synchronous and asynchronous computations combined. For example, `log "\nTut12 - Task.rejected example"` is performed synchronously in the `do` block of `main` , while `\x →  log $ "success " <> show x` is performed asynchronously.  What I love about `purescript-aff` is that you feel like you're writing synchronous code, and relieved from the task of writing tedious callbacks in JavaScript.

I've also rewritten "launchMissles" and "rejectMissles" from the Tutorial12 repository to use async computation, so check out my [repository]()  to see those examples.  Note, they're using the concepts that are covered in the Tutorial13 example below, so let's move on and explore a couple of new type signatures.

Yes, the type alias for `TaskE` is a little dense.  First, let’s understand what is `ExceptT x`.  Without going down into the Monad rabbit hole, you can think of `ExceptT` as a wrapper which adds exceptions `x` to other monads.  In our case, the other monad in this structure is `(Aff e) `, and we know, from the discussion above, that exceptions are an effect from Aff.  Fun fact - the `T` in `ExceptT`  stands for *transformation* because we are transforming our `(Aff e) ` monad into one that can handle both exceptions and effects.  As you’re going to see shortly, under the hood, we use our old friend `Either`.


The function `fork` also requires some careful attention.  Looking at the type signature, it takes two function arguments, `(a → Aff e c) ` and `(b → Aff e c ) ` , our `Task a e b` and it returns our asynchronous computation with effects, `Aff e c`.  Now, if you've looked at `fork` from Folktale.js, we pass in our error and success computations, and so we're doing the same here with the first two arguments.  Next, we use `toAff` to turn our task into the form `Aff e (Either x a) `, where `e` represents our effects, and `x`  & `a`represent our error and success function arguments from above.  Take a look at the function signature for [runExceptT](https://pursuit.purescript.org/search?q=runExceptT) to see how `runExceptT` accomplishes this feat.

 Next, for the function `either` to process this `Aff e (Either x a) `, we unwrap `(Either x a) ` from `Aff e` by using our bind operator `(>>=) `.  With bind then, at last, we have our return type which again is `Aff e c`.  So this asynchronous computation is ready to go, handling both the error or success computations.  However, for this computation to execute, we need to launch it using `launchAff`.   I show that process in the next code snippet.

## Implementing newTask
If you have looked at Brian's [video]() you'll see that the main example is reading a configuration file and writing out a new port number using `Task` from Folktale.js  We're going to do the same here, but naturally with PureScript.  However, first, we've got a few more functions to cover from my Task library that helps us with this example.  If you’re not interested in the details behind the implementation of Task, then you skip to *Reading and writing to a file using Task* below.  First up is `newTask`:

```haskell
newTask
  ∷ ∀ e x a
  . ((Either Error (Either x a → Eff e Unit) → Eff e (Canceler e)) 
  → TaskE x e a
newTask =
  ExceptT <<< makeAff
```
Here again, the type signature is a little dense, but essentially we are providing this function with a callback and a canceler and returning a new asynchronous Task.  The callback says that the computation produces either an `Error` or a function from `(Either x a → Eff e Unit) `.  Moreover, we have two `Either` constructors nested together to form this callback.  Rest assured that we are implementing `Task` in terms of PureScript's `Aff` type, but with `ExceptT` layered on top to provide a polymorphically-typed error channel.  Thus, instead of restricting our errors to the JavaScript error type, we allow representations like `String` or perhaps an error code with `Int`, or whatever you like.   To make this work, we compose `makeAff ` together with `ExceptT`.  

What's left in this signature is the `Canceler e`, which tells `makeAff` how to clean up after the async computation.  For example, if an async process is killed and an async action is pending, then the canceler is called to clean up.  In our case, we don't have any elaborate async processes so, as you'll see below,  we can provide newTask with the `NonCanceler`.  Which, as you may suspect, provides `makeAff` with a canceler that doesn't cancel anything.  With this out of the way, we're ready to show how to read and write to a file asynchronously using `Task`.

## Reading and writing to a file using Task

 
 

## Resources
* [Principled, Painless Asynchronous Programming in PureScript](https://github.com/degoes-consulting/lambdaconf-2015/blob/master/speakers/jdegoes/async-purescript/presentation.md) - John Degoes
* [Async Programming](https://www.youtube.com/watch?v=dbM72ap30TE) - Nate Faubion, LA PureScript Meetup 12/95/17


## Navigation
[<--](https://github.com/adkelley/javascript-to-purescript/tree/master/tut12) Tutorials [-->](https://github.com/adkelley/javascript-to-purescript/tree/master/tut14)

You may find that the README for the next tutorial is under construction. But if you're an eager beaver and would like to look ahead, then all the of code samples from Brian's [videos](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) have been ported to PureScript already. But I may amend them as I write the accompanying tutorial markdown.  
