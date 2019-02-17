

# Write applicatives for concurrent actions

[series banner](file:///Users/Gibson/Dropbox/code/purescript/javascript-to-purescript/resources/glitched-abstract.jpg)

> **Note: This is** **Tutorial 21** **in the series** **Make the leap from JavaScript to PureScript**. Be sure
> **to read the series introduction where we cover the goals & outline, and the installation,**
> **compilation, & running of PureScript. I’ll be publishing a new tutorial approximately**
> **once-per-month. So come back often, there’s a lot more to come!**
> 
> [Index](https:github.com/adkelley/javascript-to-purescript/tree/master/md) | [<< Introduction](https:github.com/adkelley/javascript-to-purescript) [< Tutorial 20](https:github.com/adkelley/javasc-to-purescript/tree/master/tut20) | [> Tutorial 22](https:github.com/adkelley/javascript-to-purescript/tree/master/tut22)

In the [last tutorial](https://github.com/adkelley/javascript-to-purescript/tree/master/tut20), we continued our exploration of Applicative Functors with a practical example that captured the pattern of nested loops for constructing
foldable (e.g., array) comprehensions.
We'll finish off applicatives in this tutorial with another example that pings a mock database, returning a result from a query. As you'll see,
a query in our example is independent of the result of previous queries. Consequently, instead of performing these queries serially, we can leverage concurrency
by employing applicatives to run them simultaneously. We'll
look at both the serial and concurrent approaches so that you can see the difference in coding.  We'll mock the "database find" method
using our homegrown `Task` module from [Tutorial 13](https:github.com/adkelley/javascript-to-purescript/tree/master/tut13).

I borrowed this series outline, and the javascript code samples with permission from the egghead.io course Professor Frisby Introduces Composable Functional JavaScript by
Brian Lonsdorf — thank you, Brian! A fundamental assumption is that you’ve watched his [video](https://egghead.io/lessons/javascript-applicatives-for-concurrent-actions) on the topic before tackling the equivalent PureScript abstraction
featured in this tutorial. Brian covers the featured concepts exceptionally well, and I feel it’s better that you understand its implementation in the comfort of JavaScript.

You'll find the text and code examples for this tutorial on [Github](https://github.com/adkelley/javascript-to-purescript/tree/master/tut20).  If you read something that you feel could be explained better, or a code example that needs refactoring,
then please let me know via a comment or send me a pull request.  Also, before leaving, please give it a start to help me publicize these tutorials.

Let's start with a quick review of `TaskE` then move onto the example.


## Reviewing the Task module

Recall from [Tutorial 13](https:github.com/adkelley/javascript-to-purescript/tree/master/tut13) that `TaskE` runs an asynchronous computation that may fail, and it models any side-effects explicitly.
There isn't a specific `TaskE` module in
PureScript, so we created one ourselves to mimic [data.task](https://folktalegithubio.readthedocs.io/en/latest/api/data/task/index.html?highlight=task) from the JavaScript [Folktale library](https://folktalegithubio.readthedocs.io/en/latest/index.html).  As you'll see, `TaskE` is a good structure to help mock a database API query,
because it runs asynchronously and allows for effects that may fail.  For example, when pinging a database endpoint, there's always
the possibility that your endpoint might be down.  Also, what if the caller invokes an invalid query? Well, in our example, we don't want to continue with the next query because
we're building a report header that's constructed from the aggregate queries. In
these and other cases, `TaskE` should fail gracefully by reporting that there's a problem back to the caller.

The type alias for `TaskE` is:

    type TaskE x a = ExceptT x Aff a

With `ExceptT x`, we're creating a structure that can fail during its computation, and
 `Aff a` denotes that it is asynchronous and produces side-effects. Note that `ExceptT x` is a monad transformer for the `Either x`
Monad, whose type we introduced in [Tutorial 3](https://github.com/adkelley/javascript-to-purescript/tree/master/tut03).

We haven't covered monad transformers in this series, and we may not have the opportunity.  However, in simple terms, `ExceptT` helps
us to handle a successful or failed computation within the `Aff` monad.  We wrap the computation with a `Right a` and `Left a` from the `Either` monad, denoting success or failure
respectively. So, we've got two monads operating together (i.e., `Aff` and `Either`) and `ExceptT` is the glue that makes this possible.

A simple and successful `TaskE` is created by wrapping the result using `pure` from [Control.Applicative](https://pursuit.purescript.org/packages/purescript-prelude/4.1.0/docs/Control.Applicative#v:pure). In Tutorial 13, we used the `taskOf` method for this purpose. It is syntax sugar for `pure` since we hadn't covered applicatives at the time.  The example below wraps the string "good task" in a Task whose computation is later run in `main`.
It is guaranteed to be successful since we're returning a string, "good task", unfettered by any side-effects.

    goodTask :: TaskE String String
    goodTask = pure $ "good task"
    
    main :: Effect Unit
    main = do
      void $ launchAff $
        goodTask
        # fork (\e → Console.log $ "error: " <> e) (\r → Console.log $ "success: " <> r)

The `launchAff` method launches an asynchronous [fiber](https://en.wikipedia.org/wiki/Fiber_(computer_science)), which in this case is `goodTask`.  The `fork` method is there to handle the two possible outcomes - either success or failure.
Ultimately, it logs "good task" to the console.  In case you're wondering how to
create a "bad" task - throw an error!  You use `throwError` with the comfort that `ExceptT` ensures that `Either` and `Aff` play nice together.

    badTask :: TaskE String String
    badTask = throwError "bad task"
    
    main :: Effect Unit
    main = do
      void $ launchAff $
        badTask
        # fork (\e → Console.log $ "error: " <> e) (\r → Console.log $ "success: " <> r)

These, are perhaps, the simplest tasks to write.  In the next section, we'll use our "database find" example to show how to add callbacks within our tasks and clean up the
fiber after finishing the asynchronous computation.


## Mocking a database query using Task

With our review of `TaskE` complete, let's move on to our mock example that queries a database API for project records and later logs the titles of those projects.
Here, we have a database of projects; each modeled with a record of type  `Project = { id :: Int, title :: String }`, where `id` is the record identifier, and `title` is the
name of the project.  We perform a query by running an asynchronous task with effects that may fail with an exception of type `String` or succeed by returning a result of
type `Project`. Also, since we're mocking an API endpoint, the `Project` record response is a time-dependent value. We can model that behavior using `setTimeout` within our Task to
mimic the delay in the response returned by the API.

    type Project = { id :: Int, title :: String }
    
    dbFind :: Int → TaskE String Project
    dbFind id =
      let
        query :: Int → Effect (Either String Project)
        query id_ = pure $ do
          let validIds = [20, 8]
          case (elemIndex id_ validIds) of
            Just _  → Right { id: id_, title: "Project: " <> (show id)}
            Nothing → Left $ "record id: " <> (show id) <> " not found."
      in
       newTask $ \callback → do
         let requestResponse = query id >>= \r →
               callback $ either (\e → rej e) (\s → res s) r
         _ <- setTimeout 100 requestResponse
         pure $ nonCanceler

Within `dbFind`, a successful query returns a `Project` record with side-effects modeled explicitly (i.e., `Effect (Right Project)`). Alternatively, in the case of
failure (i.e., `Effect (Left String)`), we return an error message that the record `id` was not found in the database.  The `newTask` method has been designed
to perform this computation by accepting (as arguments) a function that transforms an effectful callback to a canceler.
We perform the query and then, using the "bind"<sup><a id="fnr.1" class="footref" href="#fn.1">1</a></sup> operation `(>>=)`, we pass the return value in sequence to
our callback.  Depending on success or failure and, with the help of the `either` function, the callback uses `res` or `rej`, respectively to wrap the result in our `TaskE`
type signature.

To simulate a time-dependent value, we call `setTimeout` to delay the `callback` by 100 milliseconds.  We're not interested in the timeout id, so we can ignore it
by not binding it to a variable.  Finally, we need to tell `makeAff` (the function underpinning `newTask`) how to clean up after our asynchronous computation.
In this case, there's no elaborate asynchronous process going on, so providing `newTask` with `nonCanceler` (a canceler that doesn't do anything) is good enough for
our purposes.


## Sequential dbFinds using Monads

As Brian shows in his [video](https://egghead.io/lessons/javascript-applicatives-for-concurrent-actions?pl=watch-later-c0bd1d3b4b63d74b), there are two approaches to executing multiple queries on a database.  The first approach executes them sequentially, as
shown below. Take this approach when the formation of a database query is dependent on the information retrieved from one or more previous queries.

In the code example below, the overall goal is to "console log" a report header constructed from our two queries, `dbFind 20` and `dbFind 8`.
We use `reportHeader` to construct a string from the two project titles. To accomplish this, we call `dbFind 20` as
our first query, which returns its result wrapped in the `TaskE`. So alas, we know we're working in the `TaskE` monad, which means we bind the first
query to the lambda function `p1` and compose it with `reportHeader` and our next query `dbFind 8` (bound to `p2)`.

    reportHeader :: Project -> Project -> String
    reportHeader p1 p2 =
      "Report: " <> p1.title <> " compared to " <> p2.title
    
    main :: Effect Unit
    main = void $ launchAff $
      dbFind 20 >>= (\p1 → (\p2 → reportHeader p1 p2) <$> dbFind 8)
      # fork (\e → Console.error e) (\p → Console.log p)

Recall that `bind`, whose infix operator is `>==`, is equivalent to `chain` in Brian's javascript examples (see example below).  The `map` function, whose infix operator is `<$>`,
lifts `reportHeader` into the `TaskE` monad so that it can operate on the `TaskE` arguments, `p1` and `p2`.  Remember that `map` is a substitute for `pure` and one `apply` operation
within an applicative expression.

For a comparison, look at the javascript code adapted from [Brian's example](https://egghead.io/lessons/javascript-applicatives-for-concurrent-actions?pl=watch-later-c0bd1d3b4b63d74b):

    const reportHeader = (p1, p2) =>
      `Report: ${p1.title} compared to ${p2.title}`
    
    Task.of (Db.find (20).chain (p1 =>
               Db.find (8).map (p2 =>
                  reportHeader (p1, p2))))
    .fork (console.error, console.log)


## Concurrent dbFinds using Applicative Functors

We know the queries, `dbFind 20` and `dbFind 8` are independent, and therefore it's not necessary to run them sequentially.  If we can run them concurrently
in an applicative expression, it helps to make our code more readable, and perhaps even execute faster.

Compared to our sequential example in the previous section, I believe the applicative expression is much more readable. In the example below, if either of these queries
fails, then execute `(\e → Console.log $ "error: " <> e)` to call out the offending query. Otherwise `reportHeader` is cleared to construct our header string which is
printed out to the console.

    main = void $ launchAff $
      (\p1 p2 → reportHeader p1 p2) <$> (dbFind 20) <*> (dbFind 8)
      # fork (\e → Console.error e) (\p → Console.log p)

Naturally, if your mental model prefers code that appears sequential, then feel free to use applicative do syntax:

    main = void $ launchAff $ ado
      p1 <- dbFind 20
      p2 <- dbFind 8
      in
      reportHeader p1 p2
      # fork (\e → Console.error e) (\p → Console.log p)

Once again, let's compare this with the Javascript code, adapted from  [Brian's video](https://egghead.io/lessons/javascript-applicatives-for-concurrent-actions?pl=watch-later-c0bd1d3b4b63d74b):

    const reportHeader = (p1, p2) =>
      `Report: ${p1.title} compared to ${p2.title}`
    
    Task.of (p1 => p2 => reportHeader (p1, p2))
    .ap (Db.find (20))
    .ap (Db.find (8))
    .fork (console.error, console.log)

Both the PureScript Javascript code examples are much easier to read, and again should execute faster than our sequential example.


## Lifting functions into applicative expressions

In the previous section, instead of using `pure` to lift `reportHeader` into the `TaskE` monad, we're using `map` whose infix operator is `<$>`. Thus, we substituted
`pure (\a b → f a b) <*> m a <*> m b` for `(\a b → f a b) <$> m a <*> m b`.  Moreover, if you review the past two tutorials, you'll see that's been our practice.
One immediate observation should be that the former is easier to read and it is the idiomatic syntax to begin using in case you're not using
`lift2, lift3, ...` or `applicative do` sugar.

So what's going on with `(\a b → f a b) <$> m a <*> m b` and why are we able to use it?  Well, it helps
to step back and look at `pure` and the infix operators for `apply` and `map`:

\#+BEGIN<sub>SRC</sub> haskell
pure  ::   (a → b) → m (a → b)
(<\*>) :: m (a → b) → m a → m b

(<$>) ::   (a → b) → m a → m b

\#+END<sub>SRC</sub>  haskell

Notice that `pure` lifts our function `a → b` into `m` to get `m (a → b)`.  Next is `apply` whose infix operator is `(<*>)`. This method takes `m (a → b)` and our
input `m a` to return our output `m b`.

Now, look at `map`, whose infix operator is `<$>`.  It lifts the function `(a → b)` into `m`, then applies it to the input `m a` and returns our output `m b`.

So, in essence, `map` enables the substitution of `pure`, and one `apply` within an applicative expression.


## Summary

In this tutorial, we refactored a sequence of independent queries using monads into an applicative expression with concurrent finds.  After refactoring,
we found that our code is not only better optimized for performance, but it is also simpler to read and understand.

We have come to the end of our tutorials that explored the practical examples using Applicative Functors.  I hope you agree that it is a dominant pattern that
you can exploit in whatever functional programming language you choose to program in.

In the next tutorial, we'll move on to explore another useful construct that allows us to `traverse` a foldable structure (e.g., array) of applicative functors and
applies a function to each.  For example, if our foldable structure is an array, then the type signature for `traverse` is `(a → f b) → Array a → f (Array b)`.  This method is useful
when our function `f` produces side-effects.  For example, imagine the array contains a list of filename paths that require reading and parsing their text.

That's all for now, and till next time!


# Footnotes

<sup><a id="fn.1" href="#fnr.1">1</a></sup> In case you're a little hazy on `bind` or even monads, then please refer to [Tutorial 16](https://github.com/adkelley/javascript-to-purescript/tree/master/tut16) for a refresher.
