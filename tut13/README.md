# Use Task for Asynchronous Actions

![Series banner](../resources/glitched-abstract.jpg)

> *This is* **Tutorial 13** *in the series* **Make the leap from JavaScript to PureScript**. Be sure
> *to read the series introduction where I cover the goals & outline, and the installation,*
> *compilation, & running of PureScript. I will be publishing a new tutorial approximately*
> *once-per-week. So come back often, there is a lot more to come!*

> [<< Introduction](https://github.com/adkelley/javascript-to-purescript) [< Tutorial 12](https://github.com/adkelley/javascript-to-purescript/tree/master/tut12)

## Introduction
Welcome to Tutorial 13 in the series **Make the leap from Javascript to PureScript**.  I hope you're enjoying it thus far.  If you're new to this series, then be sure to read the series [Introduction](https://github.com/adkelley/javascript-to-purescript) to learn how to install and run PureScript.  The series outline and javascript code samples were borrowed with permission from the egghead.io course [Professor Frisby Introduces Composable Functional JavaScript](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) by
[Brian Lonsdorf](https://github.com/DrBoolean) - thank you, Brian! A fundamental assumption of each tutorial is that you've watched his video before tackling the equivalent PureScript abstraction featured in this tutorial.  Brian covers the featured concepts exceptionally well, and I feel it's better that you understand his implementation first, in the comfort of JavaScript.  

In this tutorial, we are going to refactor our structure `Task` from [Tutorial 12](https://github.com/adkelley/javascript-to-purescript/tree/master/tut12) so that it mimics a standard node callback style based workflow - minus the callbacks! If you recall, I mentioned we could implement [FolkTale] (http://folktalegithubio.readthedocs.io/en/latest/api/data/task/index.html?highlight=task)'s `Task` using two approaches.  The first is Continuation Passing Style (CPS) which we covered in the last tutorial and the second is using asynchronous computation, which we'll utilize in this tutorial.   I should also mention again that, unlike [Elm](http://package.elm-lang.org/packages/elm-lang/core/latest/Task) or FolkTale, there is no `Task` package or structure in PureScript.  We don't need it, because all of the functionality is available in PureScript already.  Instead, we piece it together into an abstraction; and that’s what I've done here.

We're going to lean heavily on the library [purescript-aff](https://pursuit.purescript.org/search?q=purescript-aff).  `Aff` stands for 'asynchronous effects'  and it allows us to write our programs as if we were writing synchronous code with effects.  However, behind the scenes, our program is operating asynchronously without any callbacks.  Moreover, error handling is baked in, so we can use the functions from `Task` to deal with it the way we want.  If you've looked at this library and wondered how to put it into action, then this tutorial is for you! 

### Shout-Out!
Before we get started, I do want to give a shout-out to Ryan Rempel [rgrempel](https://github.com/rgrempel).  I hadn't used `Aff` before, so what I learned and drew inspiration from was his [purescript-elm-compat](https://github.com/rgrempel/purescript-elm-compat), and I essentially lifted his `Task` type structure verbatim.  I would encourage you to have a look this repository because there's wealth of best practices in functional programming waiting for you to discover.  Thank you, Ryan!  

### Housekeeping
In my [Tutorial 13 repository](https://github.com/adkelley/javascript-to-purescript/tree/master/tut13), you'll find that, in addition to the new examples from Brian's [video](https://egghead.io/lessons/javascript-using-task-for-asynchronous-actions), I've rewritten the examples from Tutorial 12 to utilize `Aff`, instead of the continuation monad `Cont`.  

Let's get started by taking a step back to discuss how to write asynchronous programs in PureScript.

## Asynchronous programming in PureScript
In [Tutorial 4 - Part 1](https://github.com/adkelley/javascript-to-purescript/tree/master/tut04P1), I introduced the topic of *side effects*.  As a review, a function or expression creates a side effect, such as logging to console, by modifying some state outside its scope, or it has an observable interaction with its calling functions or the outside world.   Now, so far, we have using the `Eff` monad to manage these side effects.  But what if we're programming asynchronously? If some asynchronous part of our program creates a side-effect, can we still use `Eff` monad to manage it?  Yes, we can. However, we need something to assemble them into our asynchronous computation, and that's the job of `Aff`.  

An `Aff eff a` is an asynchronous computation with effects `eff`.  The computation may error with an exception, or produce a type a.
You can find `Aff` and its supporting cast of types and functions in the module [purescript-aff](https://pursuit.purescript.org/packages/purescript-aff/4.1.1).  One of the primary goals of this module is that asynchronous programming shouldn't look any different than synchronous programming, as you`ll see in my examples below.  If you're familiar with how AJAX works in JavaScript then under the hood, `Aff eff a` works similar to this example from John Degoes' Lamda Conference 2015 [presentation](https://github.com/degoes-consulting/lambdaconf-2015/blob/master/speakers/jdegoes/async-purescript/presentation.md) :

``` haskell
ajaxGet  ::  ∀ eff.  String →  Aff (ajax  :: AJAX | eff) 
```
``` javascript
function ajaxGet(url) {
  return function(success, failure) {  // <- Aff!
    ...
    return canceler;
  };
}
``` 
I encourage to read his presentation because it elaborates on the concepts that I am presenting below.  Now, on to our *task* at hand.

###  Task.purs
In my [GitHub repository](), I suggest the first file you look at is `Task.purs`.   In that module, you'll find the following type and functions:

```haskell
type TaskE x e a = ExceptT x (Aff e) a

taskOf :: ∀ x e a. a -> TaskE x e a
taskOf = pure

taskRejected :: ∀ x e a. x -> TaskE x e a
taskRejected = throwError

toAff :: ∀ e x a. TaskE x e a → Aff e (Either x a)
toAff = runExceptT

fork
  :: ∀ c e b a
   . (a → Aff e c) → (b → Aff e c) → TaskE a e b
   → Aff e c
fork f g t = do
  result ← toAff t
  either f g result
```
Yes, the type alias for `TaskE` is a little dense.  First, let’s understand what is `ExceptT x`.  Without going down into the Monad rabbit hole, you can think of `ExceptT` as a wrapper which adds exceptions `x` to other monads.  In our case, the other monad in this structure is `(Aff e) `, and we know, from the discussion above, that exceptions are an effect from Aff.  Fun fact - the `T` in `ExceptT`  stands for *transformation* because we are transforming our `(Aff e) ` monad into one that can handle both exceptions and effects.  As you’re going to see shortly, under the hood, we use our old friend `Either`.

Now, if you recall from Brian's video, `Task.rejected(x)` in FolkTale.js  is a way to invoke a failure in your computation.  So, in my case, `taskRejected` we'll throw an error, and `fork` will decide how to handle it on the other end. 
Before delving into `fork` let’s take care of `TaskOf`.  This function wraps our polymorphic argument `a` around our `TaskE` structure, and we accomplish it by using the function `pure`.   Going forward, you're going to see `pure` a lot more because it's our *goto* function for wrapping monads.  For example, `TaskOf 1` returns the structure `TaskE x e 1`, where `x` and `e` are still polymorphic until we make them concrete types by calling `fork`.

The function `fork` also requires some careful attention.  Looking at the type signature, it takes two function arguments, `(a → Aff e c) ` and `(b → Aff e c ) ` , our `Task a e b` and it returns our asynchronous computation with effects, `Aff e c`.  Now, if you've looked at `fork` from Folktale.js, we pass in our error and success computations, and so we're doing the same here with the first two arguments.  Next, we use `toAff` to turn our task into the form `Aff e (Either x a) `, where `e` represents our effects, and `x`  & `a` represent our error and success function arguments from above.  Take a look at the function signature for [runExceptT](https://pursuit.purescript.org/search?q=runExceptT) to see how `runExceptT` accomplishes this feat.

 Next, for the function `either` to process this `Aff e (Either x a) `, we unwrap `(Either x a) ` from `Aff e` by using our bind operator `(>>=) `.  With bind then, at last, we have our return type which again is `Aff e c`.  So this asynchronous computation is ready to go, handling both the error or success computations.  However, for this computation to execute, we need to launch it using `launchAff`.   I show that process in the next code snippet.

## Tutorial 12 revisited 

Now, `tut12Rej` performs the opposite.  If you recall from above, `taskReject` rejects the task by throwing an error.  So, in this case, we will always "fork left" and log "err bad task" to the console.  Again, these computations aren't run until we launch them using `launchAff`.  Our `main` module takes the honor in performing this function.  It returns our effects along with `Unit`.  However, it's important to recognize that logging the result of this computation to the console was performed asynchronously. In contrast, `log "\nTut12 - Task.rejected example"` was performed synchronously.  What I love about `purescript-aff` is that you feel like you're writing synchronous code, and relieved from the task of writing tedious callbacks in JavaScript.

``` haskell
tut12Res :: ∀ eff. Aff (console :: CONSOLE | eff) Unit
tut12Res =
  taskOf "good task"
  # fork (\e → log $ "err " <> e) (\x → log $ "success " <> show x)

tut12Rej :: ∀ eff. Aff (console :: CONSOLE | eff) Unit
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
I've also rewritten "launchMissles" and "rejectMissles" from the Tutorial12 repository to use async computation.  However, they're using the concepts that are covered in the Tutorial13 example below, so let's move on.

## Reading and writing a file using Task


## Resources
* [Principled, Painless Asynchronous Programming in PureScript](https://github.com/degoes-consulting/lambdaconf-2015/blob/master/speakers/jdegoes/async-purescript/presentation.md) - John Degoes
* [Async Programming](https://www.youtube.com/watch?v=dbM72ap30TE) - Nate Faubion, LA PureScript Meetup 12/95/17


## Navigation
[<--](https://github.com/adkelley/javascript-to-purescript/tree/master/tut12) Tutorials [-->](https://github.com/adkelley/javascript-to-purescript/tree/master/tut14)

You may find that the README for the next tutorial is under construction. But if you're an eager beaver and would like to look ahead, then all the of code samples from Brian's [videos](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) have been ported to PureScript already. But I may amend them as I write the accompanying tutorial markdown.  
