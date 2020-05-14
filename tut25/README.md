# Apply Natural Transformations in everyday work

![series banner](../resources/glitched-abstract.jpg)

> **Note: This is** **Tutorial 25** **in the series** **Make the leap from JavaScript to PureScript**. Be sure
> **to read the series introduction where we cover the goals & outline, and the installation,**
> **compilation, & running of PureScript. I’ll be publishing a new tutorial approximately**
> **once-per-month. So come back often, there’s a lot more to come!**
> 
> [Index](https:github.com/adkelley/javascript-to-purescript/tree/master/md) | [<< Introduction](https:github.com/adkelley/javascript-to-purescript) [< Tutorial 24](https:github.com/adkelley/javascript-to-purescript/tree/master/tut24) [Tutorial 27 >>](https:github.com/adkelley/javascript-to-purescript/tree/master/tut27)

In the [last tutorial](https://github.com/adkelley/javascript-to-purescript/tree/master/tut24/), we began looking at natural transformations in functional programming - what they are and their laws.  In this tutorial, we'll continue on this topic by showing how to leverage natural transformations within your code.  To review, a natural transformation is a function that takes a functor holding some `a` to another functor holding that `a` (i.e. `F a -> G a`).

I borrowed this series outline, and the JavaScript code samples with permission from the egghead.io course Professor Frisby Introduces Composable Functional JavaScript by
Brian Lonsdorf — thank you, Brian! A fundamental assumption is that you've watched his [video](https://egghead.io/lessons/javascript-applying-natural-transformations-in-everyday-work) on the topic before tackling the equivalent PureScript abstraction
featured in this tutorial. Brian covers the featured concepts exceptionally well, and I feel it's better that you understand its implementation in the comfort of JavaScript.

You'll find the text and code examples for this tutorial on [Github](https://github.com/adkelley/javascript-to-purescript/tree/master/tut25).  If you read something that you feel could be explained better, or a code example that needs refactoring, then please let me know via a comment or send me a pull request.  Also, before leaving, please give it a star to help me publicize these tutorials.


## Case 1: When a function doesn’t support your type constructor

What do you do when a library function doesn’t support your type constructor?  Do you write it yourself?  Instead, consider using a natural transformation.  In Brian’s [example](https://egghead.io/lessons/javascript-principled-type-conversions-with-natural-transformations), there’s no instance of `chain` for Javascript arrays.  Consequently, we’re not able to split on a character directly:

    /* This won't work - no instance of chain on arrays */
    ['hello', 'world']
    .chain(x => x.split(''))

To solve this problem, he used a natural transformation to turn the array into a list, knowing that `chain` exists on the `List` type constructor.

    const res = List(['hello', 'world'])
    .chain(x => List(x.split('')))

Terminal Output

    List [ "h", "e", "l", "l", "o", "w", "o", "r", "l", "d" ]

PureScript’s `Array` has an instance of `bind` (infix operator `>==`), which is the equivalent to `chain` above.  Thus, we can act on the array directly to split its words into characters.  But imagine having a `List` of words!  Now we have a problem because `split` from [Data.String.Common](https://pursuit.purescript.org/packages/purescript-strings/4.0.1/docs/Data.String.Common#v:split) supports arrays only!  So, similar to Brian’s solution, we use natural transformations between `List` and `Array`.  We perform them using `fromFoldable`; available in both [Data.Array](https://pursuit.purescript.org/packages/purescript-arrays/5.3.0/docs/Data.Array#v:fromFoldable) and [Data.List](https://pursuit.purescript.org/packages/purescript-lists/5.4.0/docs/Data.List#v:fromFoldable).  The type signature for `fromFoldable` in `Data.Array` is:

    fromFoldable :: forall f. Foldable f => f ~> Array

It converts any `Foldable` structure into `Array`.  For example:

    fromFoldable (Just 1) = [1]
    fromFoldable (Nothing) = []

Notice the `~>` in `fromFoldable`'s type signature.  It is the infix operator for `NaturalTransformation`, and its a signal to not only the compiler but to anyone reading your code that this function will perform a natural transformation. With that explanation, let's see how we can convert a list of words to characters in PureScript:

    import Data.Array (fromFoldable) as A
    import Data.List (fromFoldable)
    import Data.String.Common (split)
    
    wordList :: List String
    wordList = ("hello" : "world" : Nil)
    
    main :: Effect Unit
    main = do
      log "\nSplit on characters from a wordList"
      logShow $ fromFoldable $
         (A.fromFoldable wordList) >>= \x -> split (Pattern "") x

In `main`, working from right to left, the steps are as follows:  1. transform `wordList` into an array using `Data.Array.fromFoldable`; 2. perform the split into characters by binding the array with `split`;  3. transform `Array` back to `List ~ with ~Data.List.fromFoldable`.


## Case 2: Accessing arbitrary elements within a foldable structure

Most functional programming languages don’t assume that an index into a foldable structure exists before attempting to access it.  For example, how can a function be pure when attempting to return the first element of an empty array? The solution is to return a type constructor that addresses this possibility, typically `Either` or `Maybe`.

The  helper functions in PureScript’s [Data.Array](https://pursuit.purescript.org/packages/purescript-arrays/5.3.0/docs/Data.Array) use the `Maybe` type constructor to address this possibility.  For example, when an array is non-empty, the helper function `Data.Array.head` returns the first element, `Just a`.  Otherwise, it returns `Nothing`.

With this in mind, let’s port Brian’s [second example](https://egghead.io/lessons/javascript-applying-natural-transformations-in-everyday-work) to PureScript:

    numbers :: Array Int
    numbers = [2, 400, 5, 1000]
    
    largeNumbers :: Array Int -> Array Int
    largeNumbers = filter (\x -> x > 100)
    
    larger :: Int -> Int
    larger = \x -> x * 2
    
    main :: Effect Unit
    main = do
      log "\nProve that head is a natural transformation"
      log $ (show $ larger <$> head (largeNumbers numbers)) <> " == "
        <> (show $ head $ larger <$> (largeNumbers numbers))

In `main`, using the commutative law covered in the previous tutorial, we prove that `head` is a natural transformation.  That is, `map larger $ head (largeNumbers numbers) == head $ map larger (largeNumbers numbers)`.   With our knowledge of natural transformations, we choose `larger <$> head (largeNumbers numbers)` because it's faster on large arrays and produces the same result as `head $ larger <$> (largeNumbers numbers)`


## Case 3: Binding multiple database queries

Our last use case example for natural transformations involves the task of querying a user and, if the query is successful, perform another query for this user’s best friend. Imagine this database of users has the following fields:

    type Id = Int
    type User = { id :: Id
                , name :: String
                , bestFriendId :: Id
                }

This example is where things get a little tricky because either query can return an error if the user `id` is less than 3. So we’ll account for this Error using the `Either` constructor in our task:

    fake :: Id -> User
    fake x = { id: x, name: "user" <> (show x), best_friend_id: (x + 1)}
    
    dbFind :: Id -> TaskE Error (Either Error User)
    dbFind id =
      let
        query :: Id -> Either Error User
        query id_ =
          if (id_ > 2)
            then Right $ fake id_
            else Left “not found”
      in
         taskOf $ query id

If we apply `dbFind` to a user `id` of 3, we get back `Task(Right {id: 3, name: "user3", bestFriendId: 4})`. In the next query, we want the best friend of `user3`, whose name is `user4`.

One approach, assuming we're unaware of natural transformations, is to map [either](https://pursuit.purescript.org/packages/purescript-either/4.1.1/docs/Data.Either#v:either) over `Task(Right {id: 3, name: "user3", bestFriendId: 4})` to get `user3` out. Then, rinse and repeat to find and return `user4`:

    notFound :: User
    notFound = {id: -1, name: "notFound", bestFriendId: -1}
    
    main :: Effect Unit
    main = do
      void $ launchAff $
        let
            s = "\nFind best friend record (no natural transformations): "
            eitherUser = either (\x -> notFound) identity
            user = \x -> map eitherUser (dbFind x)
            bestFriend = user 3 >>= \x -> user x.bestFriendId
        in
         bestFriend
         # fork (\e -> Console.error $ s <> e) (\p -> Console.log (s <> (show p)))

Terminal Output:

    Find best friend record (no natural transformations): { bestFriendId: 5, id: 4, name: "user4" }

I can attest that this code was challenging to write, let alone follow!  Moreover, when a user record doesn't exist, we return `{id: -1, name: "notFound", bestFriendId: -1}`, which isn't what we want.  Rather, the computation should fail and forgo the second query.

The correct approach is to use the natural transformation `eitherToTask` to turn that inner `Either` (i.e., `Task(Right {id: 3, name: "user3", bestFriendId: 4})`) into a task `Task(Task {id: 3, name: "user3", bestFriendId: 4}`. Then, bind it to get `user3` and rinse and repeat to get `user4`:

    eitherToTask :: forall a. Either Error a -> TaskE Error a
    eitherToTask = either (\e -> taskRejected e) (\a -> taskOf a)
    
    main :: Effect Unit
    main = do
      void $ launchAff $
        let s = "\nFind best friend record (natural transformations): "
        in do
         (dbFind 3) >>= eitherToTask >>= \user -> (dbFind user.bestFriendId) >>= eitherToTask
         # fork (\e -> Console.error $ s <> e) (\p -> Console.log (s <> (show p)))

Much better!  Our `eitherToTask` found their ids and returned the right results even though we’ve transformed our eithers into tasks. Before calling `fork`, we’re left with `Task(Task {user: 4, name: "user4", bestFriendId: 5})`.  The function `fork` resolves both tasks and our output to the console is:

    Find best friend record (natural transformations): { bestFriendId: 5, id: 4, name: "user4" }


## Summary

In this tutorial, we covered three use cases for using natural transformations in our everyday code.  The first case showed how natural transformations could be used to transform a data structure to match the type required by a function.  In the example, we showed how a `List` is naturally transformed into an `Array` using `Data.Array.fromFoldable`.  The second example focused on turning the first element of an `Array` into a `Maybe` type constructor. This transformation is useful in cases where the `Array` may be empty, and we’re looking for safety.  Finally, we showed how to naturally transform a composition of multiple database queries in order to bind them together more efficiently.  This approach avoids nested map functions and leads to a correct solution and more readable code.

In the next tutorial, we’ll move onto a new topic - isomorphisms and round trip data transformations. That’s all for now.   If you are enjoying these tutorials, then please help me to tell others by recommending this article and favoring it on social media.  Till next time!

