

# Write applicatives for concurrent actions


## Introduction

[series banner](file:///Users/Gibson/Dropbox/code/purescript/javascript-to-purescript/resources/glitched-abstract.jpg)

> **Note: This is** **Tutorial 21** **in the series** **Make the leap from JavaScript to PureScript**. Be sure
> **to read the series introduction where we cover the goals & outline, and the installation,**
> **compilation, & running of PureScript. I’ll be publishing a new tutorial approximately**
> **once-per-month. So come back often, there’s a lot more to come!**
> 
> [Index](https:github.com/adkelley/javascript-to-purescript/tree/master/md) | [<< Introduction](https:github.com/adkelley/javascript-to-purescript) [< Tutorial 20](https:github.com/adkelley/javasc-to-purescript/tree/master/tut20) | [> Tutorial 22](https:github.com/adkelley/javascript-to-purescript/tree/master/tut22)

In the [last tutorial](https://github.com/adkelley/javascript-to-purescript/tree/master/tut20), we continued our exploration of Applicative Functors with an example that captured the pattern of nested loops for constructing
foldable (e.g., list, array, etc.) comprehensions.
We'll finish off applicatives in this tutorial with an example that pings a mock database, returning results from multiple queries. As  you'll see in the example,
our queries are independent of the result of previous ones. Thus, instead of performing these queries serially, we can leverage concurrency
by employing applicatives to run multiple queries simultaneiously. But we'll
look at both serial and concurrent approaches, so that you can see the difference and implement them yourself in the future.  We'll mock our database queries
using our homegrown `Task` module from [Tutorial 13](https:github.com/adkelley/javascript-to-purescript/tree/master/tut13), so we'll start with a quick review of `Task`.

I borrowed this series outline, and the javascript code samples with permission from the egghead.io course Professor Frisby Introduces Composable Functional JavaScript by
Brian Lonsdorf — thank you, Brian! A fundamental assumption is that you’ve watched his [video](https://egghead.io/lessons/javascript-applicatives-for-concurrent-actions) on the topic before tackling the equivalent PureScript abstraction
featured in this tutorial. Brian covers the featured concepts exceptionally well, and I feel it’s better that you understand its implementation in the comfort of JavaScript.

You'll find the text and code examples for this tutorial on [Github](https://github.com/adkelley/javascript-to-purescript/tree/master/tut20).  If you read something that you feel could be explained better, or a code example that needs refactoring,
then please let me know via a comment or send me a pull request.  Also, before leaving, please give it a start to help me publicize these tutorials.


## Reviewing the Task module

Recall from [Tutorial 13](https:github.com/adkelley/javascript-to-purescript/tree/master/tut13) that `Task` allows us to, among several things, run an asynchronus computation and model its side-effects explicitly.
There isn't a specific `Task` module in
PureScript, so we created one ourselves to mimic [data.task](https://folktalegithubio.readthedocs.io/en/latest/api/data/task/index.html?highlight=task) from the [Folktale library](https://folktalegithubio.readthedocs.io/en/latest/index.html), written in JavaScript.  As I mentioned in the introduction, as part of the example, we're
going to mock a database api query. `Task` is a good structure by which to accomplish this, so let's do a short review.

A `Task` when implemented asynchronously, represents asynchronous effects that may fail.  For example, when you think about pinging a database endpoint, there's always the
remote possibility that the endpoint might be down.  In this case, `Task` should fail gracefully by reporting that there's a problem back to the caller. The type alias for
an asynchronous `Task` is:

    type TaskE x a = ExceptT x Aff a

Note that I've named this type signature `TaskE` because its ability to handle exceptions.  With `ExceptT x`, we're creating a structure that can properly fail during its
computation, and
 `Aff a` denotes that the computation is ansynchronous and produces side-effects. Here's a litte more information about `ExceptT x` - it's a monad transformer for the `Either x`
monad, whose type we introduced in [Tutorial 3](https://github.com/adkelley/javascript-to-purescript/tree/master/tut03). We haven't covered monad transformers, and we won't in this series.  However, as a simple explanation, `ExceptT` helps
us to handle a <span class="underline">success</span> or <span class="underline">failure</span> computation by the `Aff` monad, which is wrapped with `Right a` and `Left a` from the `Either` monad respectively. So, essentially, we have
two monads operating together (i.e., `Either` and `Aff`) and `ExceptT` is the glue that makes this possible.

A simple Task can be created by wrapping a successful computation using `pure` from [Control.Applicative](https://pursuit.purescript.org/packages/purescript-prelude/4.1.0/docs/Control.Applicative#v:pure). In Tutorial 13, we used `taskOf` but this was just syntax sugar for `pure`,
since we hadn't covered applicatives at the time.  The example below wraps the string "good task" in a Task whose computation is later run in `main`.
It is guaranteed to be successful, since we're returning the string, "good task", unfettered by any side-effects.

    goodTask :: TaskE String String
    goodTask = pure $ "good task"
    
    main :: Effect Unit
    main = do
      void $ launchAff $
        goodTask
        # fork (\e → Console.log $ "error: " <> e) (\r → Console.log $ "success: " <> r)

Note that `launchAff` launches an asychronous [fiber](https://en.wikipedia.org/wiki/Fiber_(computer_science)), which in this case is `goodTask`, and `fork` is there to handle the two possible outcomes -
either success or failure.  Ultimately, the result of our computation (i.e., the string, "good task") will be logged to the console.  In case you're wondering how to
create a "bad" task - just throw an error!  You use `throwError` with the comfort of knowing that `ExceptT` has your back.

    badTask :: TaskE String String
    badTask = throwError "bad task"
    
    main :: Effect Unit
    main = do
      void $ launchAff $
        badTask
        # fork (\e → Console.log $ "error: " <> e) (\r → Console.log $ "success: " <> r)

These, are perhaps, the simplest tasks one can write.  In the next section, we'll use our DB query example to show how we can add callbacks within our tasks, and clean up the
fiber after the asynchronous computation.


## Mocking a database query using Task

With our review of `Task` complete, let's move on to our example which a mock that queries a database API for project records and later logs the titles of those projects.
Here, we have a database of projects; each modeled with record of type  `Project = { id :: Int, title :: String }`, where `id` is the record identifier, and `title` is the
name of the project.  We perform a query by running an asynchronous `TaskE` that may fail with an exception of type `String`, or succeed by returning a result of
type `Project`. Also, since we're mocking an API endpoint, the `Project` record response is a time dependent value. We can model that behavior using `setTimeout` within our
Task to mimic the delay in a response returned by the API.

    type Project = { id :: Int, title :: String }
    
    dbFind :: Int → TaskE String Project
    dbFind id =
      let
        query :: Int → Effect (Either String Project)
        query id_ = do
          let validIds = [20, 8]
          case (elemIndex id_ validIds) of
            Just _  → pure $ Right { id: id_, title: "Project: " <> (show id)}
            Nothing → pure $ Left $ "record id: " <> (show id) <> " not found."
      in
       newTask $ \cb → do
         let requestResponse = query id >>= \r →
               cb $ either (\e → rej e) (\s → res s) r
         _ <- setTimeout 100 requestResponse
         pure $ nonCanceler

Within `dbFind`, a query successfully returns an effectual time dependent value of type `Project` (i.e., `Effect (Right Project)`) or failure (i.e., `Effect (Left String)`) in case
the record id was not found.  The function `newTask` employs `makeAff` to construct an `Aff` from effects (e.g., a database query) using a callback and a canceler.
So we wrap our `cb` and `nonCanceler` in `newTask`, respectively. We perform the query and then, using the "bind"<sup><a id="fnr.1" class="footref" href="#fn.1">1</a></sup> operation `(>>=)`, we pass the return value in sequence to
our callback.  With the help of the `either` function, depending on success or failure, the callback uses `res` or `rej` to wrap the result in our `TaskE` type signature.

To simulate a time dependent value, we call `setTimeout` to delay the query-response by 100 milliseconds.  We're not interested in the timeout id, so we can ignore
by not binding it to any variable.  Finally, we need to tell `makeAff` (the underpinning function in `newTask`) how to clean up after the asynchronous computation.
In this case, there's no elaborate asynchronous process going on here, so providing `newTask` with `nonCanceler` (a canceler that doesn't do anything) is good enough for
our purposes.


## Sequential dbFinds using Monads

As Brian shows in his [video](https://egghead.io/lessons/javascript-applicatives-for-concurrent-actions?pl=watch-later-c0bd1d3b4b63d74b), there are two approaches to executing multiple queries on an API endpoint.  The first approach executes them sequentially, as shown below. This is
the approach to take when the formation of a database query is dependent on the information retrieved from one or more previous qeries.

In the code example below, the overall goal is to log a report header to the console that was constructed from our two queries, `dbFind 20` and `dbFind 8`.
We use `reportHeader` to contruct the header string using the two project titles from our two queries. Two accomplish this, we call `dbFind 20` with
our first query, which returns a result that's wrapped in the `TaskE` monad. So alas, we know we're working in the `TaskE` monad, which means we need to bind the first
query to the function `p1` and compose it with `dbFind 8`, which in turn is bound to `p2`.

Now that we have the result of our two queries, all that's left is to call
`ReportHeader`. But, for `ReportHeader` to be able to work with the functions `p1` and `p2` we'll need to lift it into the `TaskE` monad<sup><a id="fnr.2" class="footref" href="#fn.2">2</a></sup> structure.
By now, hopefully you're aware that this can be accomplished using `pure`, from PureScript's Control.Applicative module. Aha! This means that `TaskE` is not only a monad, but its
also an applicative functor, which serves as a nice sequeway into the next section.

    reportHeader :: Project -> Project -> String
    reportHeader p1 p2 =
      foldr (<>) "" ["Report: ", p1.title, " compared to ", p2.title]
    
    main = void $ launchAff $
      dbFind 20 >>=
        (\p1 → dbFind 8 >>=
           \p2 → pure $ reportHeader p1 p2)
      # fork (\e → Console.log $ "error: " <> e) (\p → Console.log p)

But first, I mentioned in Tutorial 16 that my head starts to spin after two or more successive bind operations.  So, syntax sugar to the rescue! Here's the same expression
using `do` notation:

    main = void $ launchAff $ do
      p1 <- dbFind 20
      p2 <- dbFind 8
      pure $ reportHeader p1 p2
      # fork (\e → Console.log $ "error: " <> e) (\p → Console.log (s <> p))


## Concurrent dbFinds using Applicative Functors

Its fine to perform database queries in sequence, especially when the formation of a query is dependent on the result from a previous query(s).  But in our case, we see
that the queries, `dbFind 20` and `dbFind 8` are independent.  Thus, if we have the ability to run them concurrently using applicatives, then perhaps it will help to make our
code more readable, and even execute faster.  Now, hopefully you're seeing that applicatives are not a theoretical exercise in functional programming, but instead an extremely useful
and powerful tool to begin leveraging in your applications.

Compared to our sequential example from the previous section, the applicative approach is much more readable and the queries `dbFind 20` & `dbFind 8` are run concurrently.
That is a "win-win" in my opinion.  If either of these queries fail, then `(\e → Console.log $ "error: " <> e)` will be executed to call out the offending query. Otherwise
`reportHeader` is cleared to construct our header string which is printed out to the console.

    main = void $ launchAff $
      (\p1 p2 → reportHeader p1 p2) <$> (dbFind 20) <*> (dbFind 8)
      # fork (\e → Console.log $ "error: " <> e) (\p → Console.log p)

Naturally, if your mental model prefers code that appears sequential, then feel free to use applicative do syntax:

    main = void $ launchAff $ ado
      p1 <- dbFind 20
      p2 <- dbFind 8
      in
      reportHeader p1 p2
      # fork (\e → Console.log $ "error: " <> e) (\p → Console.log p)

Finally, please read the next section to understand why and how I was able to
use `f (p1 p2) <$> m p1 <*> m p2` instead of (`pure $ f (p1 p2)) <*> m p1 <*> m p2`.


## A note on lifting functions into Applicative Functors

In the previous section, instead of using `pure` to lift `reportHeader` into the `TaskE` monad, we're using `map` whose infix operator is `<$>`. Thus, we substituted
`pure (\a b → f a b) <*> m a <*> m b` for `(\a b → f a b) <$> m a <*> m b`.   One immediate observation should be that the former is easier to read and, as you'll see shortly,
it is ideomatic syntax to begin using in case you're not using `lift2, lift3, etc.` or `applicative do` sugar.

So what's going on with `(\a b → f a b) <$> m a <*> m b` and why are we able to use it?  Well, it helps
to step back and review `pure` and the infix operaters for `apply` and `map`:

\#+BEGIN<sub>SRC</sub> haskell
pure  ::   (a → b) → m (a → b)
(<\*>) :: m (a → b) → m a → m b

(<$>) ::   (a → b) → m a → m b

\#+END<sub>SRC</sub>  haskell

Notice that `pure` lifts our function `a → b` into `m` to get `m (a → b)`.  Next is `apply` whose infix operator is `(<*>)`. This method takes `m (a → b)` and our
input `m a` to return our output `m b`.

Now look at `map`, whose infix operater is `<$>`.  It lifts the function `(a → b)` into `m`, then applys it to the input `m a` and returns our output `m b`.

So, in essence, `map` enables the substitution of `pure` and one `apply` from a partially applied expression!

\#+BEGIN<sub>SRC</sub> haskell

f :: ∀ a b m. (a → b) → m a → m b
f = pure (a → b) <\*> m a

g :: ∀ a b m. (a → b) → m a → m b
g = (a → b) <$> m a

\#+END<sub>SRC</sub>  haskell

So, going forward, when paritally applying a function to multiple applicative arguments, substitute `pure` and the first `apply` with `map`. Just as we did in the previous section:
`(\a b → f a b) <$> m a <*> m b` `≡ pure (\a b -> f a b) <*> m p1 <*> m p2`.


## Conclusion

In this tutorial, we refactored a sequence of two independent queries using monads into an applicative expression with two concurrent finds.  After refeactoring,
we found that our code performs better but its also easier to read and reason about.

We come to the end of our tutorials that explored the practical examples using Applicative Functors.  I hope you agree that it is an extremely useful pattern that
can exploit in whatever language you choose to program in.  As an exercise, I suggest you take a look at your past code projects and look for opportunities to refactor
using the applicative.

In the next tutorial we'll move on to explore another useful construct that allows us to traverse a foldable structure (e.g., array) of applicative functors and
apply a function to each.  For example, if our foldable structure is an array then the type signature for `traverse` is `(a → f b) → Array a → f (Array b)`.  This is useful
when our function `f` involves side-effects.  For example, imagine the array contains a list of filename paths to read.

That's all for now.


# Footnotes

<sup><a id="fn.1" href="#fnr.1">1</a></sup> In case you're a little hazy on `bind` or even monads then please refer to [Tutorial 16](https://github.com/adkelley/javascript-to-purescript/tree/master/tut16) for a refresher.

<sup><a id="fn.2" href="#fnr.2">2</a></sup> hopefully this idea of lifting a function into a context is beginning to sink in.
