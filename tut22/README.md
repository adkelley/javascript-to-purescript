

# Leapfrogging types with Traversable

[series banner](../resources/glitched-abstract.jpg)

> **Note: This is** **Tutorial 22** **in the series** **Make the leap from JavaScript to PureScript**. Be sure
> **to read the series introduction where we cover the goals & outline, and the installation,**
> **compilation, & running of PureScript. I’ll be publishing a new tutorial approximately**
> **once-per-month. So come back often, there’s a lot more to come!**
> 
> [Index](https:github.com/adkelley/javascript-to-purescript/tree/master/md) | [<< Introduction](https:github.com/adkelley/javascript-to-purescript) [< Tutorial 21](https:github.com/adkelley/javascript-to-purescript/tree/master/tut21)

In the [last tutorial](https://github.com/adkelley/javascript-to-purescript/tree/master/tut21/), we concluded our extensive exploration of `Functor` type classes, by ending with the `Applicative Functor`. Now, in this tutorial, we'll look at a new type class that has a relationship with `Functor`, called `Traversable`.   Throughout our `Functor` exploration the transformation functions processed the elements within a `Functor` type class (using `map`, `apply` or `bind`) while preserving the structure of the original `Functor`. For example, `map (\x -> x + 1) [1, 2, 3]` takes the array `[1, 2, 3]` and returns a new array `[2, 3, 4]`, leaving the outer structure intact.  However, what if we what to change the original `Functor` to another type constructor?  For example, perhaps we want `Array String` to become \`Maybe (Array String)~ to reflect the overall success or failure of our transformation function.   That is the topic of this and the next tutorial - commuting two types, turning
the these structures inside out.

I borrowed this series outline, and the JavaScript code samples with permission from the egghead.io course Professor Frisby Introduces Composable Functional JavaScript by
Brian Lonsdorf — thank you, Brian! A fundamental assumption is that you've watched his [video](https://egghead.io/lessons/javascript-leapfrogging-types-with-traversable) on the topic before tackling the equivalent PureScript abstraction
featured in this tutorial. Brian covers the featured concepts exceptionally well, and I feel it's better that you understand its implementation in the comfort of JavaScript.

You'll find the text and code examples for this tutorial on [Github](https://github.com/adkelley/javascript-to-purescript/tree/master/tut22).  If you read something that you feel could be explained better, or a code example that needs refactoring, then please let me know via a comment or send me a pull request.  Also, before leaving, please give it a star to help me publicize these tutorials.


## One final review of functors

I mentioned above that `Traversable` has a relationship with the `Functor` type class.  To help explain this relationship, let's take stock of the functors we have covered thus far.  Back in [Tutorial 14](https://github.com/adkelley/javascript-to-purescript/tree/master/tut14/), we started with the most basic and ubiquitous type class in functional programming, namely the `Functor`.   Any type constructor that supports a mapping operation is considered a `Functor`.  Examples of `Functor` type constructors include `List`, `Array`, `Maybe`, `Task`, `Either`, and many more.  The `map` operation allows us to transform the elements inside the `Functor` uniformly while preserving the structure and shape of the type constructor.

In [Tutorial 18](https://github.com/adkelley/javascript-to-purescript/tree/master/tut18/), we looked at the `Applicative Functor`, which is a subclass of `Functor` that adds the `apply` and `pure` operations.  The `apply` operation is similar to `map`, but it differs because it acts on transformation functions that are wrapped in a functor.  We do that using `pure` , which lifts a value or expression into `Functor`.  Then we can apply (i.e., `<*>`) this function over multiple functor arguments; for example: `pure (+) <*> [1] <*> [2, 3] = [3, 4]`.

Finally, in [Tutorial 16](https://github.com/adkelley/javascript-to-purescript/tree/master/tut16), we covered the `Monad` type class, which is a subclass of the `Applicative Functor`.  `Monad` not only supports the `map` and `pure` operations, but also `bind`.  The `bind` operation helps to prevent double nesting of the `Functor` when applying multiple sequential operations to it; avoiding messes like `Just (Just a)`.

With our review out of functors out of the way, we can move on to `Traversable`, which holds a relationship with `Functor`.


## The Traversable Class

I mentioned that the `Traversable` type class has a relationship with functors.  That's because every `Traversable` is an `Applicative Functor` that is `Foldable`.  By `Foldable`, I mean type constructors
that can be folded, such as a `List` or `Array,` to return a value.  I didn't cover [Data.Foldable](https://pursuit.purescript.org/packages/purescript-foldable-traversable/4.1.1/docs/Data.Foldable) formally, but we looked at a couple of its methods, `foldMap` and `foldr`
in [Tutorial 10](https://github.com/adkelley/javascript-to-purescript/tree/master/tut10).  Like `map`, the two operations within
the `Traversable` class allow us to transform the elements within the Functor.  Moreover, like `Foldable`, we accumulate the results and effects of this transformation function along the way into an `Applicative Functor`.

For a simple example, imagine you have an array of string elements that you wish to parse, but one or more of these elements may be invalid.  The function signature is, `parseStrings :: Array String -> Array (Maybe String)`, where the `Maybe` type constructor represents the possibility of a valid or invalid string.  If this is what we want, then the `map` operation suffices - `map (\x -> Maybe x) (Array String) = Array (Maybe String)`  However, what if we want  `parseStrings`  to signal a failure whenever it encounters an invalid string within the array? In this case, our type signature becomes `parseStrings :: Array String -> Maybe (Array String)`.  Unfortunately `map` is not up to this task; therefore, we rely on one of the member functions from the `Traversable` class to help complete this job.


### Member functions

There are two member functions associated with `Traversable`, `sequence` and `traverse` .  The `sequence` operation is perhaps the simplest to grok.  From the purescript REPL (i.e., `pulp psci`), you see that `sequence` turns our foldable functor structure inside out:

    > import Data.Traversable
    > :t sequence
    forall a m t. Traversable t => Applicative m => t (m a) -> m (t a)

For example, imagine you have `Array (Maybe a)`, but you want to transform it to `Maybe (Array a)` , to signal the overall success or failure of the transformation function used to process the array elements.
Let's try a few examples at the REPL to work it out:

    > import Data.Traversable
    > import Data.Maybe
    > p = \x -> if (x > 0) then (Just x) else Nothing
    > process1 = map p [1, 2, 3]
    > sequence process1
    Just [1, 2, 3]
    > process2 = map p [1, -1, 3]
    > sequence process2
    Nothing

From the above, `sequence` lifts the resulting accumulation outside of the structure, turning it inside out.  Thus, when all the elements pass the predicate function (e.g., `process1`, it returns `Just (Array Int)`.  When one of the elements fails the predicate function (i.e., `process2`), it returns `Nothing`.

The `sequence` function is perfectly fine, assuming you've processed every element within the `Foldable` structure in advance.  However, you may be wondering whether there's also a way to act on every element at the same time. For this type of functionality, we use `traverse` :

    > import Data.Traversable
    > :t traverse
    forall a b m t. Traversable t => Applicative m => (a -> m b) -> t a -> m (t b)

Using the same predicate function from above, we can play with `traverse` in the purescript REPL:

    > import Data.Traversable
    > import Data.Maybe
    > p = \x -> if (x > 0) then (Just x) else Nothing
    > traverse p [1, 2, 3]
    Just [1, 2, 3]
    > traverse p [1, -1, 3]
    Nothing

In summary, whenever we want to commute two types like this, what we can do instead of calling `map` followed by `sequence` is to call `traverse`. It's nice and short!

From the above example, we can also infer that `sequence` is equivalent to  `traverse identity`, where `identity` is the identity function `\x -> x`.  Fun fact - the `sequence` operation is actually implemented in the purescript library using `traverse identity`
(See [purescript-foldable-traversable](https://github.com/purescript/purescript-foldable-traversable/blob/v4.1.1/src/Data/Traversable.purs#L73)).  Also, vice versa, `traverse f xs` is equivalent to `sequence (map f xs)`.

Now, with the `sequence` and `traverse` operations in our back pocket, let's move onto the example from Brian's [video](https://egghead.io/lessons/javascript-leapfrogging-types-with-traversable).


## Example

In Brian's video, we lean on our `Task` module (see [Tutorial 13](https://github.com/adkelley/javascript-to-purescript/tree/master/tut13)) once again to read multiple files asynchronously, wrapping each file in a Task:

    const fs = require('fs')
    const Task = require('data.task')
    const futurize = require('futurize').futurize(Task)
    const { List } = require('immutable-ext')
    
    const readFile = futurize(fs.readFile)
    const files = ['box.js', 'config.json']
    const res = files.map(fn => readFile(fn, 'utf-8'))
    console.log(res)

which returns an array of tasks:

Terminal output:

    [ Task { fork: [Function], cleanup: [Function] },
      Task { fork: [Function], cleanup: [Function] } ]

The problem becomes knowing when all the Tasks finish and how to fork each one. We'll solve this shortly with `traverse`.   First, here's how to achieve the equivalent example in purescript:

    files :: Array String
    files = ["./resources/Box.purs", "./resources/config.json"]
    
    taskReadTextFile :: String → TaskE Error String
    taskReadTextFile fname =
      let
        tryReadTextFile :: String → Effect (Either Error String)
        tryReadTextFile fname_ = try $ readTextFile UTF8 fname_
      in
        newTask $ \callback → do
          tryReadTextFile fname >>= \r →
            callback $ either (\e → rej e) (\s → res s) r
          pure $ nonCanceler
    
    main :: Effect unit
    main =
    void $ launchAff $
       map (\x -> taskReadFile x) files #
       (\rs -> Console.log $ show rs)

Note that the last line generates a compiler error because there's no class instance of `show` for `TaskE`.  We don't need to write it, but if we did, then we could make the text look similar to the terminal output from the JavaScript code above.

Let's move onto the solution we're seeking, by turning these
type constructors inside out, so that `Task` is on the outside of the `Array`.

    main :: Effect Unit
    main =
      void $ launchAff $
        traverse (\x → taskReadTextFile x) files
        # fork (\e → Console.error $ show e) (\rs → Console.log $ foldl (<>) "" rs)

Upon executing `traverse (\x -> taskReadfile x) files`, the resulting type is `TaskE (Array String)`, assuming there were no errors while reading our files.  Then, after executing `fork`, we concatenate the array elements using `foldl` and log the text from each of the files to the console.  Otherwise, the type result becomes `TaskE Error`.


## Summary

In this tutorial, we introduced a new type class, `Traversable` that holds a relationship with the `Foldable`  and `Functor` type classes. The member functions within `Traversable` will commute two types: `t (m a)  -> m (t a)`.  Here `t` belongs to `Foldable` and `Functor` type classes, and `m` is an `Applicative Functor`, confirming there is the relationship mentioned above.

Example use cases for `Traversable`, covered above, include signaling the overall success or failure of a function when mapping `(a -> m b)` over a foldable functor of elements `t a`.  We can use `sequence $ map (a -> m b) (t a)` or the shorter `traverse (a -> m b) (t a)`  operation.  The result is the same - `m (t b)`, turning these two types, `m` and `t`, inside out.  We can also leverage `Traversable` to execute multiple Tasks within a foldable structure and fork the entire structure at once to end up with a list of results.

In the next tutorial, we'll continue with another example of using `Traversable` to resolve a list of tasks of HTTP requests.  That's all for now.   If you are enjoying these tutorials, then please help me to tell others by recommending this article and favoring it on social media.  Till next time!

