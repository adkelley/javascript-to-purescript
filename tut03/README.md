# Enforce a null check with composable code branching using Either

![series banner](../resources/glitched-abstract.jpg)

> *Note: This is* **Tutorial 3** *in the series* **Make the leap from JavaScript to PureScript** *. Be sure*
> *to read the series introduction where we cover the goals & outline, and the installation,*
> *compilation, & running of PureScript. I will be publishing a new tutorial approximately*
> *once-per-week. So come back often, there is a lot more to come!*

> [Index](https://github.com/adkelley/javascript-to-purescript/tree/master/index.md) | [<< Introduction](https://github.com/adkelley/javascript-to-purescript/tree/blob/master/README.md) [< Tutorial 2](https://github.com/adkelley/javascript-to-purescript/tree/master/tut02) | [Tutorial 4 - Part 1 >](https://github.com/adkelley/javascript-to-purescript/tree/master/tut04P1) [>> Tutorial 20](https://github.com/adkelley/javascript-to-purescript/tree/master/tut20)

The series outline and javascript code samples were borrowed with permission from the egghead.io course 
[Brian Lonsdorf](https://github.com/DrBoolean) - thank you, Brian! A fundamental assumption of each tutorial is that you've watched his video before tackling the equivalent PureScript abstraction featured in this tutorial.  Brian covers the featured concepts extremely well, and I feel it's better that you understand its implementation in the comfort of JavaScript.  

For this tutorial, we're going to introduce the Either type and use it to express a computation as a sequence of functions that may or may not succeed.  Then we'll try it out to enforce a null check and branch our code (see [video3](https://egghead.io/lessons/javascript-composable-code-branching-with-either)) If you read something that you feel could be explained better, or a code example that needs refactoring, then please let me know via a comment or send me a pull request on [Github](https://github.com/adkelley/javascript-to-purescript/tree/master/tut03).

## Either

We're going to move on from `Box` in the previous tutorials to explore the `Either` functor. `Either a b` will always contain a value of `a` or `b`,  defined by the constructor’s `Left a` or `Right b`, but never both at the same time.  We often use `Either` to express a computation as a sequence of functions that may or may not succeed.  For example, a successful computation could be designated by `Right b` and failure during one of the functions by `Left a`.  Note that you can assign the meaning of `Left a` or `Right b` to be whatever you want.  But sticking with convention, let’s go with success to mean `Right b` and failure to be `Left a`.   First, we’ll look at the `Either ` functor in JavaScript to help illustrate this point.  Later on, we’ll show how `Either` is implemented in PureScript.

### Type Annotation (JavaScript)

```javascript
const Right = x =>
({
  map: f => Right(f(x)),
  fold: (f, g) => g(x),
  inspect: () => `Right(${x})`
})

const Left = x =>
({
  map: f => Left(x),
  fold: (f, g) => f(x),
  inspect: () => `Left(${x})`
})
```

Notice above that when a computation is successful then mapping over our `Right` functor performs no differently than `Box` from Tutorials 1 and 2.  Like `Box` we continue to map functions over `Right` until we return the final result using `fold`.  Now `fold: (f, g) ` is interesting and different than what we've seen so far.  If you will recall, the `fold`  function in `Box` removes the value from the type after we run the function.  But with `Either`, we have two types `Left` and `Right`, and we typically don't know which type we have until we're ready to fold.  So the function `fold` handles `Left` and `Right` by applying one of the two functions we supply.  If our type constructor is `Right` then apply `g(x)`; if its `Left` then apply `f(x)` and finally return the result.

It is the `Left` constructor that makes the `Either` functor more flexible than `Box`.  With `Left` we can perform pure functional error handling, instead of creating a side-effect (e.g., throwing an exception).  If a function fails during the computation then return `Left a`, where `a` could be assigned an error message detailing where and what happened.  Finally, prevent mapping over `Left` for the remainder of the computation.  I hope you will agree that this is much better than crashing the program or returning a null value with no reason why.

### Type Annotation (PureScript)

There’s no need to write the `Either` type class declaration in PureScript ourselves because it is a core component of most functional programming languages.  You'll find it in the module `purescript-either` located on [github](https://github.com/purescript/purescript-either)

```purescript
data Either a b = Left a | Right b
```

Simple enough - `Either a b` is a data type where, by common convention, `Left` can be used to carry an error value and `Right` takes a success value.  Also the values `a` and `b` are polymorphic in this declaration, meaning when we declare their types they can be a string, integer, float, etc. and they don't have to be the same type.

Below is the functor class instance for `Either` which tells the PureScript compiler how to map over it. Note the function `either` is equivalent to our `fold` function from the JavaScript type signature above.  It is not a class instance, but just a normal function.

```purescript
instance functorEither :: Functor (Either a) where
  map _ (Left x) = Left x
  map f (Right y) = Right (f y)

either :: forall a b c. (a -> c) -> (b -> c) -> Either a b -> c
either f _ (Left a) = f a
either _ g (Right b) = g b
```

It should be clear that there’s no difference mapping over the Either functor in JavaScript or PureScript.  Moreover, except for the difference in names, `either` and `fold` perform identically.  Finally, we won't be console logging `Left` or `Right` in our code example this time, but here's the `showEither` class instance which is equivalent to `inspect` in our JavaScript constructors.

```purescript
instance showEither :: (Show a, Show b) => Show (Either a b) where
  show (Left x) = "(Left " <> show x <> ")"
  show (Right y) = "(Right " <> show y <> ")"
```

## Code Example: findColor

We're going to return the hex value of a color requested by the user from a collection of colors.  When we find the user's color, return its hex value sans ‘#.’  If we don't find it, we’re not going to throw an exception, return a null value or some other silly side effect.  Instead, we’ll use pure functional error handling using Either's `Left` constructor to return a message to the user.  You can find the entire code example on [github]((https://github.com/adkelley/javascript-to-purescript/tree/master/tut03/src))

To use Either and perform FFI, we include a few more package dependencies in our `psc-package.json` file .  I’ve done this already by adding the `purescript-lists`, `purescript-either` and `purescript-functions` in addition to the default dependencies.  But if you are starting a fresh project, then you could use `psc-package install either && psc-package install functions && psc-package install lists` to add these dependencies.  Note that the PureScript compiler is ‘package manager agnostic’ so if you don't like psc-package then feel free to use another package manager, such as [bower](https://bower.io/). You'll find that I support bower right out of the box by including a `bower.json` file in each tutorial directory.

### Revisit Javascript FFI with a twist

This section will be a slight review from our foreign function interface (FFI) discussion in Tutorial 2.  This time, instead of a single argument, we’re calling a JavaScript function with multiple arguments.  We call the Javascript function `slice` from PureScript to remove the `#` mark from our color hex value. Let’s see how we can accomplish this from PureScript.

First the PureScript function, followed by our JavaScript implementation `sliceImpl` in Main.js:

```purescript
foreign import sliceImpl :: Fn3 Int Int String String

slice :: Int -> Int -> String -> String
slice begin end string =
  runFn3 sliceImpl begin end string
```

```javascript
"use strict";

exports.sliceImpl = function(beginIndex, endIndex, string) {
  if (endIndex === 0) {
    return string.slice(beginIndex);
  } else {
    return string.slice(beginIndex, endIndex);
  }
};
```

From the top, we declare our foreign import `sliceImpl ` as a function `Fn3` that takes three arguments that represent the beginning, and ending indexes of our input string; returning our sliced substring. Compare that with our FFI declaration of `unsafeParseFloat` below from Tutorial 2, and you’ll find them to be different:

```purescript
foreign import unsafeParseFloat :: String -> Number
```

While `sliceImpl ` has multiple arguments, `unsafeParseFloat` has just one argument and looks like any other PureScript function declaration that we’ve seen so far.  What’s going on?  Well, all PureScript functions take exactly one argument and simulate functions of multiple arguments via [currying](https://en.wikipedia.org/wiki/Currying), which is standard in many functional programming languages such as Haskell.  We could have declared `sliceImpl` with the following:

```purescript
foreign import sliceImpl :: Int -> Int -> String -> String
```

But if we do that, then we’ll have to write our JavaScript code to curry these arguments manually.  In this case, `sliceImpl` in `Main.js` would be written as follows:

```javascript
"use strict";

exports.sliceImpl = function(beginIndex) {
  return function(endIndex) {
    return function(string) {
      if (endIndex === 0) {
        return string.slice(beginIndex);
      } else {
        return string.slice(beginIndex, endIndex);
      }
    }
  }
};
```

The moral of this story is that manually currying our JavaScript code to be compiled by PureScript is tedious and error prone.  We want to write our JavaScript functions as we normally do.  So, fortunately, PureScript provides us with an alternative: `Fn0 to Fn10` coupled with `runFn0 to runFn10 ` and is available from the module `Data.Function.Uncurried`.  If you’re still wondering why/how to accomplish this, then take a look at this PureScript [wiki page](https://github.com/purescript/documentation/blob/master/guides/FFI-Tips.md) for a simpler example.

### Declare types in PureScript

The declarations below are one of the reasons why I love PureScript (and Haskell) so much because I can be more expressive with my type signatures.  So instead of  `String` or `Unit`, I can better express its use in my application by aliasing them to `ColorName`, `HexValue`, and `Error`.

```purescript
type ColorName = String
type HexValue = String
type Error = Unit
```

I believe it helps anyone reading my code to understand what’s happening in each of my functions.  Later on, if I decide to express `Error` as a string, I can do that without having to go back and change all the type annotations for my functions. Look at the type annotations in the next section, and hopefully, you’ll see what I mean.

The next type declaration is even more impressive.  We use `data` to combine our types `ColorName` and `HexValue` into a composite type `Color`.  This structure is an *algebraic data type* and [wikipedia](https://en.wikipedia.org/wiki/Algebraic_data_type) has an excellent discussion on the topic.

```purescript
data Color = Color ColorName HexValue
```

### Find the user's color

With our type declarations out of the way, it is time to search for the user’s color in `Colors` using the function `findColor`.  First, the JavaScript function followed by PureScript:

```javascript
const fromNullable = x =>
  x != null ? Right(x) : Left(null)

const masterColors = { red: '#ff4444', yellow: '#fff68f', blue: '#4444ff' }

const findColor = name => {
  return fromNullable((masterColors)[name])
}

const resultColor = findColor('blue')
                    .map(c => c.slice(1))
                    .fold(e => 'No color',
                          c => c.toUpperCase())
```

The JavaScript example is straightforward. We create a hash map of color objects with the color names as keys.  When the name maps to an object in the collection, then the hex value is returned wrapped in the `Right` constructor.  When it doesn’t, then the hash lookup will return `null` but wrapped nice and tight in the `Left` constructor.  We’ll use the PureScript example below to explain this sequence of operations further.

```purescript
masterColors :: Colors
masterColors = (Color "red" "#ff4444")  :
               (Color "blue" "#44ff44") :
               (Color "yellow" "#fff68f") : Nil

fromList :: forall a. List a -> Either Unit a
fromList xs =
  if (null xs)
    then Left unit
    else Right $ unsafePartial fromJust $ head xs

findColor :: ColorName -> Either Error Color
findColor colorName =
  fromList $ dropWhile (\(Color n _) -> n /= colorName) masterColors

hex :: Color -> HexValue
hex (Color n h) = h

result :: ColorName -> String
result name =
  findColor name #
  map hex #
  map (slice 1 0) #
  either (\e -> "No color") toUpper
```

From the top, I'm using a List to hold the list of master colors.  We create this list by consing the colors together using `(:)`, which is the infix operator for `cons`.  The next function `fromList` is similar to `fromNullable` from the JavaScript example.  We'll cover it during the explanation of `findColor`.  

The two functions in `findColor` that are pertinent to our discussion are `dropWhile` followed by `fromList`.  Let’s take them one at a time: The `dropWhile` function takes a predicate together with a collection, and drops elements while the condition is true; stopping (returning the remaining elements) once the condition is false.  Naturally, if the condition remains true, then return an empty list or array, etc.  Otherwise, the value that caused the predicate to be false will be at the front of the collection.  

So `dropWhile` will stop iterating over the collection as soon as it finds the user's color.  Using reverse logic, we express this predicate as `(\Color n _) -> n /= name`, which essentially means "drop colors while `ColorName` is not equal to `name`."  With the help of pattern matching, we can ignore `HexValue` (the second type in `Color`) and focus on `ColorName`.  Now assuming we have a very long list of unique colors that contains the user's color, then this will be more efficient than filtering over the entire collection. Had I chose `filter predicate collection`, `filter` would’ve examined every color in the list; even after finding the user’s color!

At last, we’re in the homestretch.  In our PureScript implementation, `dropWhile` has either found the user's color and it is now sitting at the head of the collection, or the collection is empty.  Similar to the Single Responsibility principle in Object Oriented programming, functions in FP should do one thing and one thing only.  So to avoid multiple expressions in `findColor`, we create another function `fromList` that will return the `Left` or `Right` constructor depending on failure or success, respectively.

The job of `fromList` is to determine whether the list is empty or not.  If it is empty then return `Left Unit`, otherwise return `Right a`, where `a` is `Color` in this case.  Notice I made the type annotation of `fromList` to be generic (i.e., `List a -> Either Unit a`).  Returning the front of a possibly empty list is such a common pattern, that it is worth me making it generic so that I can reuse it in other projects.

If the color exists, I use `head xs` to get it from the front of the list.  PureScript is always thinking about mitigating side effects, so given there's the possibility that a list may be empty, `head` will return a `Maybe`.  Well, I've already done a 'null check', so I know that `head` is going to return `Just Color`.  Therefore I can carry on with `fromJust` to get the color out of the `Just` constructor. PureScript lets me do that by using `unsafePartial`, which is our way of telling the compiler that yes, I know there’s the possibility that the list may be empty. But not in this case, so just give me the damn color!

After returning `Left Unit` or `Right Color`, our `result` function will, assuming we found the color, map over `Right` to extract the hex portion, remove the `#` sign.  If no color was found then `map` is prevented from applying these functions.  Once again it's time to fold 'em and go home. The `either` function takes care of this, returning `No color` in case of `Left` or, in case of `Right`, transform the hex string to upper case.  

## Summary

This tutorial was rather long, so if you made it all the way through then thank you for your time, and I hope it was worth it.  We introduced a new functor `Either`, which is more flexible than the `Box` functor from our previous tutorials because it allows us to do pure functional error handling.  So instead of generating side effects, we can use `Left a` constructor to tell the user that the computation has failed and why.  But if it succeeds then we wrap it with `Right b`, and mapping over `Right` is the same as mapping over `Box`.  Our `fold` function is a little different because it accounts for two types `Left` and `Right`, so we supply it two functions `f` and `g`.  If it's the `Right` constructor (i.e., success), then run the second function `g` and return the result.  If it's the `Left` constructor (i.e., failure), then apply and return the result of the first function `f`.

Our JavaScript and PureScript implementations of `findColor` were relatively identical in implementation.  But we were able to use more expressive types in PureScript thanks to the `type` and `data` constructors. For example, using `type HexValue = String` allowed us to better express the built-in type `String` in the context of our application.  Later, if we decide to change the type of `HexValue`, then we don't need to modify the type annotations of our functions.  Finally, we used `data` to denote our algebraic data type `Color` which is a composite of the type constructors `ColorName` and `HexValue`.

That's all for now, next time we’ll cover how to use `chain` (i.e., `bind` in PureScript) to compose error handling with nested Eithers.  Stay tuned!



## Navigation
[<< Introduction](https://github.com/adkelley/javascript-to-purescript) [< Tutorial 2](https://github.com/adkelley/javascript-to-purescript/tree/master/tut02) | [> Tutorial 4 ](https://github.com/adkelley/javascript-to-purescript/tree/master/tut04P1)

You may find that the README for the next tutorial is under construction. But if you're an eager beaver and would like to look ahead, then most of the code samples from Brian's [videos](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) have been ported to PureScript already. But I may amend them as I write the accompanying tutorial markdown.  
