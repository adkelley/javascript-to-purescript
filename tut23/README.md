# Maintaining structure whilst asyncing

![series banner](../resources/glitched-abstract.jpg)

> **Note: This is** **Tutorial 23** **in the series** **Make the leap from JavaScript to PureScript**. Be sure
> **to read the series introduction where we cover the goals & outline, and the installation,**
> **compilation, & running of PureScript. I’ll be publishing a new tutorial approximately**
> **once-per-month. So come back often, there’s a lot more to come!**
> 
> [Index](https:github.com/adkelley/javascript-to-purescript/tree/master/md) | [<< Introduction](https:github.com/adkelley/javascript-to-purescript) [< Tutorial 22](https:github.com/adkelley/javascript-to-purescript/tree/master/tut22) | [Tutorial 24 >](https:github.com/adkelley/javascript-to-purescript/tree/master/tut24) [Tutorial 25 >>](https:github.com/adkelley/javascript-to-purescript/tree/master/tut25)

In the [last tutorial](https://github.com/adkelley/javascript-to-purescript/tree/master/tut22/), we looked at a new type class called `Traversable`.  We found that its member functions can commute two types, such as `Array (Maybe a)`; turning these structures inside out: `Maybe (Array a)`.  In this case, it reflects the overall success or failure of our transformation function. This is useful when your transformation is part of a chain of functions, and you need to halt this sequence whenever there's a processing error.  We’ll continue with another example of `Traversable` by simulating a sequence of `HTTP GET` requests that resolves when all these requests have resolved; similar to [Promise.all()](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/all) in JavaScript. Then, I’ll show how to perform two traversals within the same workflow; useful when you have an `Array (Array a)` to process. Again, this leans heavily on the [previous tutorial](https://github.com/adkelley/javascript-to-purescript/tree/master/tut22/), so be sure you have read and coded the exercises.

I borrowed this series outline, and the JavaScript code samples with permission from the egghead.io course Professor Frisby Introduces Composable Functional JavaScript by
Brian Lonsdorf — thank you, Brian! A fundamental assumption is that you’ve watched his [video](https://egghead.io/lessons/javascript-maintaining-structure-whilst-asyncing) on the topic before tackling the equivalent PureScript abstraction
featured in this tutorial. Brian covers the featured concepts exceptionally well, and I feel it’s better that you understand its implementation in the comfort of JavaScript.

You’ll find the text and code examples for this tutorial on [Github](https://github.com/adkelley/javascript-to-purescript/tree/master/tut22).  If you read something that you feel could be explained better, or a code example that needs refactoring, then please let me know via a comment or send me a pull request.  Also, before leaving, please give it a star to help me publicize these tutorials.


## Traversable's member functions

From the [last tutorial](https://github.com/adkelley/javascript-to-purescript/tree/master/tut22/), we learned that the two member functions belonging to the `Traversable` class are `sequence` and `traverse`.  First, the `sequence` function commutes two types `T1 (T2 a)` to `T2 (T1 a)`.

For example, imagine we want to turn an `Array` of `String` into an `Array` of `Maybe (String)`, followed by commuting these structures to obtain `Maybe (Array String)`.  The rationale for inverting these types is to signal the overall success (i.e., `Just (Array String)`) or failure (i.e., `Nothing`) in transforming each of the string elements.  This way, if this function is part of a chain of functions then, in case of `Nothing` the computation chain halts and we handle the error subsequently.  Using `map` and `sequence` the approach is:

-   First our mapping function: `map (\s -> Maybe String) (Array String)`, which results in `Array (Maybe String)`
-   Next, our `sequence` function: `sequence Array (Maybe String)`, which results in `Maybe (Array String)`

The other member function, `traverse,` performs the above map and commute operations all in the same expression. Its type signature is `forall a b m t. Traversable t => Applicative m => (a -> m b) -> t a -> m (t b)`. Thus, the two operations, `map` and `sequence`, are reduced to:
`traverse (\s -> Maybe String) (Array String)`, which results in `Maybe (Array String)`. We’ll use `traverse` in both asynchronous processing examples below.


## Mapping HTTP Get Requests

Imagine we have a `Map` of key/value pairs representing routes within our website, so that we can `map` over it to obtain the contents of each page.  In Javascript, we might represent this `Map` as:

    Map({home: '/', about: '/about-us', blog: '/blog'})
    .map

When you `.map` over a `Map`, it transforms each value, taking as input a path for every key.  In Purescript,  `Map` is a foldable data structure with the key/value pairs wrapped in a `Tuple`. More flexible than Javascript objects, our key/value pairs can be of any type. I'll use `Map String String` for both examples below.  The Purescript representation for our `Map` of routes looks like:

    (fromFoldable [(Tuple "home:" "/"), (Tuple "about:" "/about-us"), (Tuple "blog:" "/blog")])

Note, there's an infix representation `(/\)` for `Tuple` in  [Data.Tuple.Nested](https://pursuit.purescript.org/search?q=Data.Tuple.Nested) which makes reading and writing these structures a little easier on the eyes:

    (fromFoldable ["home:" /\ "/", "about:" /\ "/about-us", "blog:" /\ "/blog"])

Now, let’s create a function that simulates an `HTTP Get` request by taking a `Path` and `Params` and returning a fake result.  We do this by wrapping each request in a `Task` that is performed sometime in the future. So, instead of `String`, we return a `Task` of `String`.  Note, we’ll ignore the `Params` argument for simplicity.

    httpGet :: Path -> Params -> TaskE Error Result
    httpGet path _ = taskOf $ path <> " result"

Once we process our `Map` of key/value pairs, we end up with a `Map` of `Task (Tuple String String)` That is, `[Task ("home:" //\ "//" <> " result"), Task ("about:" /\ "/about-us" <> " result"), Task ("blog:" /\ "/blog" <> " result")]` However, similar to the last tutorial, we don’t want `Array (Task (Tuple String String))`. Instead, we want one `Task` on the outside, with all the `HTTP Get` requests resolved.  Then, when we `fork` this outside `Task`, we end up with a `Map` of key/value pairs, and all the results from out `HTTP Get` requests.  Let’s call on `traverse`, followed by `fork` to do just that:

    main :: Effect Unit
    main = do
      void $ launchAff $
        traverse (\path -> httpGet path "{}") routes #
        fork (\e -> Console.errorShow e) (\rs -> Console.logShow rs)

When we run this at the terminal, the output is:

    (fromFoldable [(Tuple "home:" "/ result"), (Tuple "about:" "/about-us result"), (Tuple "blog:" "/blog result")])

In reality, we can traverse as much as we want.  For example, let's say we want to `traverse` over a `Map` whose values are an array of multiple routes? Note in the example below, `home:` is represented as
`/home` or `/`:

    (fromFoldable ["home:" /\ ["/home, "/"], "about:" /\ ["/about-us"], "blog:" /\ ["/blog"]])

Instead of mapping twice, we simply traverse twice:

    main :: Effect Unit
    main = do
      void $ launchAff $
        traverse (\paths -> traverse (\path -> httpGet path "{}") paths) multiRoutes #
        fork (\e -> Console.errorShow e) (\rs -> Console.logShow rs)

and our terminal output will look like this:

    (fromFoldable [(Tuple "home:" ["/ result", "/home result"], (Tuple "about:" ["/about-us result"]), (Tuple "blog:" ["/blog result"]))])


## Summary

In this tutorial, we explored another application of `traverse` from the `Traversable` class, namely processing a foldable structure of asynchronous functions while maintaining its structure. For example, similar to [Promise.all()](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/all) in JavaScript, we may want to resolve a list of `HTTP Get` requests that download the contents of the list of web pages.

Another popular use case is reading from a customer database: `readCustomerFromDB :: customerID -> Maybe Customer`; returning `Just Customer` when we find the customer record, or `Nothing` otherwise.  Now, what if we have a list of `customerID` to process?  We can use `map`, to return a list of `Maybe Customer`.  But also, when `readCustomerFromDB` is part of a chain of functions, we can use `traverse` to return `Maybe (List Customer)`.  This way, the computation halts within the chain and we deal with the error.

In the next tutorial, we’ll cover a new topic of **natural transformations** in functional programming.  These come in handy, for example, when you want to split an array of
word strings `["hello", "world"]` into a list of characters `('h', 'e', 'l', 'l', 'o', 'w', 'o', 'r', 'l', 'd')`.  If you are enjoying these tutorials, then please help me to tell others by recommending this article and favoring it on social media.  Till next time!

