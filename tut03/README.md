# Enforce a null check with composable code branching using Either

![series banner](../resources/glitched-abstract.jpg)

> *Note: This is* **Tutorial 3** *in the series* **Make the leap from JavaScript to PureScript** *. Be sure*
> *to read the series introduction where we cover the goals & outline, and the installation,*
> *compilation, & running of PureScript. I will be publishing a new tutorial approximately*
> *once-per-week. So come back often, there is a lot more to come!*

> [<< Introduction](https://github.com/adkelley/javascript-to-purescript) [< Tutorial 2](https://github.com/adkelley/javascript-to-purescript/tree/master/tut02) | [> Tutorial 4](https://github.com/adkelley/javascript-to-purescript/tree/master/tut04)

The series outline and javascript code samples were borrowed with permission from the egghead.io course [Professor Frisby Introduces Composable Functional JavaScript](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) by
[Brian Lonsdorf](https://github.com/DrBoolean) - thank you, Brian! A fundamental assumption of each tutorial is that you've watched his video before tackling the equivalent PureScript abstraction featured in this tutorial.  Brian covers the featured concepts extremely well, and I feel it's better that you understand its implementation in the comfort of JavaScript.  For this tutorial, we're going to define the Either type and see how it works.  Then we'll try it out in a program to enforce a null check and branch our code (see [video3](https://egghead.io/lessons/javascript-composable-code-branching-with-either))

One more time with feeling - You should be already somewhat familiar with the **Either** abstraction by watching Brian's [video](https://egghead.io/lessons/javascript-composable-code-branching-with-either). You're also able to enter `bower update && pulp run` and `pulp run` after that, to load the library dependencies, compile the program, and run the PureScript code example.  Finally, if you read something that you feel could be explained better, or a code example that needs refactoring, then please let me know via a comment or send me a pull request on [Github](https://github.com/adkelley/javascript-to-purescript/tree/master/tut03). Let's go!

## Either

We're going to move on from `Box` in the previous tutorials to explore the `Either` functor. `Either a b` will always contain a value of `a` or `b`,  defined by the constructor’s `Left a` or `Right b`, but never both at the same time.  We often use `Either` to express a computation as a sequence of functions that may or may not succeed.  For example, a successful computation could be designated by `Right b` and failure during one of the functions by `Left a`.  Note that you can assign the meaning of `Left a` or `Right b` to be whatever you want.  But for the sake of convention let’s go with success to mean `Right b` and failure to be `Left a`.   First, we’ll look at the `Either ` functor in JavaScript to help illustrate this point.  Later on, we’ll show how `Either` is implemented in PureScript.

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

From the code snippet above, notice that when a computation is successful then mapping over our `Right` functor performs no differently than `Box` from Tutorials 1 and 2.  Like `Box` we continue to map functions over `Right` until we return the final result using `fold`.  Now `fold: (f, g) ` is interesting and different than what we've seen so far.  If you will recall, the `fold`  function in `Box` removes the value from the type after we run the function.  But with `Either`, we have two types `Left` and `Right`, and we don't know whether our computation has succeeded or failed until we return the result.  The function `fold` handles these two cases by applying one of the two functions we supply.  If our type constructor is `Right` then apply `g(x) `; if its `Left` then apply `f(x)`

The `Left` constructor is what makes the `Either` functor more flexible than `Box`.  With `Left`, we can perform pure functional error handling, rather than creating a side-effect like throwing an exception or returning a null value.  During our computation, if a function fails then we return `Left a`, where `a` can be assigned an error message, and we stop mapping over `Left` throughout the rest of the program.  This much better than crashing the program or returning a null value; leaving the user high and dry figuring out what went wrong.

### Type Annotation (PureScript)

Fortunately, there’s no need to write the type declaration in PureScript ourselves, because `Either` is a core component of most functional programming languages.  You'll find it in the module `purescript-either` located on [github](https://github.com/purescript/purescript-either)

```purescript
data Either a b = Left a | Right b
```

Simple enough: `Either a b` is a data type where, by common convention, `Left` can be used to carry an error value and `Right` takes a success value.  Also the values a and b are polymorphic in this declaration, meaning when we declare types of the values `a` and `b` they can be a string, integer, float, etc. and they don't have to be the same type.

Like `Box` we declare our instances and, in this case, let's limit them to `map` and `either`, with `either` being equivalent to our `fold` function from the JavaScript type signature above.

```purescript
instance functorEither :: Functor (Either a) where
  map _ (Left x) = Left x
  map f (Right y) = Right (f y)

either :: forall a b c. (a -> c) -> (b -> c) -> Either a b -> c
either f _ (Left a) = f a
either _ g (Right b) = g b
```

Hopefully, it is clear that there’s no difference mapping over the Either functor in JavaScript or PureScript.  Moreover, except the difference in names, `either` and `fold` perform identically.  Finally, the `showEither` class instance:

```purescript
instance showEither :: (Show a, Show b) => Show (Either a b) where
  show (Left x) = "(Left " <> show x <> ")"
  show (Right y) = "(Right " <> show y <> ")"
```

There's nothing new here when compared to our `showBox` class instance from Tutorials 1 or 2.  We’re just telling the PureScript compiler how to format our constructors whenever we log them to the console.

## Code Example: findColor

We're going to return the hex value of a color requested by the user from a collection of colors.  When we find the color, return its hex value sans ‘#.’  If we don't find it, we’re not going to throw an exception, return a null value or some other silly side effect.  Instead, we’ll use pure functional error handling using Either's `Left` constructor to return an error message to the user.  You can find the entire code example [here]((https://github.com/adkelley/javascript-to-purescript/tree/master/tut03/src))

To use Either and perform FFI, we include a few more package dependencies in our `bower.json` file .  I’ve done this already by adding the `purescript-either` and `purescript-functions` in addition to the default dependencies.  But if you are starting a fresh project, then you could use `bower install purescript-either --save && bower install purescript-functions --save` to add these dependencies.  Note that the PureScript compiler is ‘package manager agnostic’ so if you don't like Bower then use another package manager, such as [purescript-npm](https://github.com/ecliptic/purescript-npm).

### Revisit Javascript FFI with a twist

This will be a slight review from our foreign function interface (FFI) discussion in Tutorial 2.  This time, instead of a single argument, we’re calling a JavaScript function with multiple arguments.  We call the Javascript function `slice` from PureScript to remove the `#` mark from our color hex value. Let’s see how we can accomplish this from PureScript.

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

While `sliceImpl ` has multiple arguments, `unsafeParseFloat ` has just one argument and looks like any other PureScript function declaration that we’ve seen so far.  What’s going on?  Well, all PureScript functions take exactly one argument and simulate functions of multiple arguments via [currying](https://en.wikipedia.org/wiki/Currying), which is standard in many functional programming languages such as Haskell.  We could have declared `sliceImpl` with the following:

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

The moral of this story is that manually currying our JavaScript code to be compiled by PureScript is tedious and error prone.  We want to write our JavaScript functions as we normally do.  So, fortunately, PureScript provides us with an alternative: `Fn0 to Fn10` coupled with `runFn0 to runFn10 ` and is available from the module `Data.Function`.  If you’re still wondering why/how to accomplish this, then take a look at this PureScript [wiki page](https://github.com/purescript/documentation/blob/master/guides/FFI-Tips.md) for a simpler example.

### Declare types in PureScript

The declarations below are one of the reasons why I love PureScript (and Haskell) so much because I can be more expressive with my type signatures.  So instead of  `String`, I can better express its use in my application by aliasing this native type to `ColorName`, `HexValue`, and `Error`.

```purescript
type ColorName = String
type HexValue = String
type Error = String
```

I believe it helps anyone reading my code to understand what’s happening in each of my functions.  Later on, if I decide to express `HexValue` as a hexadecimal number, I can do that without having to go back and change all the type annotations for my functions. Look at the type annotations below, and hopefully, you’ll see what I mean.

The next type declaration is even more impressive.  We use `data` to combine our types `ColorName` and `HexValue` into a composite type `Color`.  This structure is an *algebraic data type* and [wikipedia](https://en.wikipedia.org/wiki/Algebraic_data_type) has an excellent discussion on the topic.

```purescript
data Color = Color ColorName HexValue
```

### Find the user's color

With our type declarations out of the way, it is time to find the user’s color in `Colors` using the function `findColor`.  First, the JavaScript function followed by PureScript:

```javascript
const fromNullable = color =>
  color != null ? Right(color) : Left(‘No color found’)

const masterColors = { red: '#ff4444', yellow: '#fff68f', blue: '#4444ff' }

const findColor = name => {
  return fromNullable((masterColors)[name])
}

const resultColor = findColor('blue')
                    .map(c => c.slice(1))
                    .fold(e => “Error: “.concat(e),
                          c => “Hex Value: “.concat(c.toUpperCase()))
```

The JavaScript example is straightforward. We create a hash map of color objects with the color names as keys.  When the name maps to an object in the collection, then the hex value is returned.  When it doesn’t, then the hash lookup will return `undefined`.  We’ll use the PureScript example below to explain this sequence of operations further.

```purescript
fromNullable :: Colors -> Either Error HexValue
fromNullable colors =
  if (null colors)
    then Left "Color was not found"
    else Right $ (\(Color _ h) -> h) $ unsafePartial head colors

masterColors :: Colors
masterColors = [ (Color "red" "#ff4444")
                          , (Color "blue" "#44ff44")
                          , (Color "yellow" "#fff68f")
                          ]

findColor :: ColorName -> Colors -> Either Error HexValue
findColor colorName colors =
  fromNullable $ dropWhile (\(Color n _) -> n /= name) masterColors

result :: ColorName -> Colors -> String
result name colors =
  findColor name colors #
  map (slice 1 0) #
  either ((<>) "Error: ") toUpper
```

The two functions in `findColor` that are pertinent to our discussion are `dropWhile` followed by `fromNullable`.  Let’s take them one at a time: The `dropWhile` function takes a predicate and a collection and drops elements while the condition is true and then stops (returning the remaining elements) once the condition is false.  Naturally, if the condition remains true, then return an empty list or array, etc.  Otherwise, the value that caused the predicate to be false will be at the front of the collection.  

So `dropWhile` will stop iterating over the collection as soon as it finds the user's color.  Using reverse logic, we express this predicate as `(\Color n _) -> n /= name`, which essentially means "drop colors while `ColorName` is not equal to `name`."  With the help of pattern matching, we can ignore `HexValue` (the second type in `Color`) and focus on `ColorName`.  Now assuming we have a very long list of unique colors that contains the user's color, then this will be more efficient than filtering over the entire collection. Had I chose `filter predicate collection`, `filter` would’ve examined every value; even after finding the user’s color!

At last, we’re in the homestretch.  In our PureScript implementation, `dropWhile` has either found the user's color and its sitting at the head of `colors` OR `colors` is empty.  Similar to the Single Responsibility principle in Object Oriented programming, functions in FP should do one thing and one thing only.  So to avoid multiple expressions in `findColor`, we create another function `fromNullable` that will return the `Left` or `Right` constructor depending on failure or success, respectively.

Our JavaScript and PureScript implementations of `fromNullable` are slightly different.  `fromNullable` in JavaScript has a single value for `x`, which is either `null` or the color's hex value.  It tests `x` and returns either `Right(x)` or `Left(‘No color found’)`.  In the PureScript example also `colors` is a collection of colors (assuming we found the color) with the user's requested color sitting at the front of the collection.  So we use `head colors` to get the first color, followed by `unsafePartial`.  The `unsafePartial` function is our way of telling PureScript that yes, you think there’s the possibility that `colors` may be empty. But not in this case, so don't worry, just give us the damn color!

## Summary

This tutorial was rather long, so if you made it all the way through then thank you for your time, and I hope it was worth it.  We introduced a new functor `Either` which is more flexible than the `Box` functor from our previous tutorials because it allows us to do pure functional error handling.  So instead of generating side effects, we can use `Left a` to indicate to the user that the computation failed and why.  But if it succeeds then use the `Right b` constructor and mapping over `Right` is the same as mapping over `Box`.  Our `fold` function is a little different by accounting for two types `Left` and `Right`, so we supply two functions `f` and `g`.  If it's the `Right` constructor (i.e., success), then run the second function `g` and return the result.  If it's the `Left` constructor (i.e., failure), then run the first function `f` and return our result.

Our JavaScript and PureScript implementations of `findColor` were relatively identical in implementation.  But we were able to use more expressive types in PureScript thanks to the `type` and `data` constructors. For example, using `type HexValue = String` allowed us to better express the built-in type `String` in the context of our application.  Later, if we decide to change the type of `HexValue`, then we don't need to modify the type annotations of our functions.  Finally, we used `data` to denote our algebraic data type `Color` which is a composite of the type constructors `ColorName` and `HexValue`.

That's all for now, next time we’ll cover how to use `chain` (i.e., `bind` in PureScript) to compose error handling with nested Eithers.  Stay tuned!





## Navigation
[<< Introduction](https://github.com/adkelley/javascript-to-purescript) [< Tutorial 2](https://github.com/adkelley/javascript-to-purescript/tree/master/tut02) | [> Tutorial 4 ](https://github.com/adkelley/javascript-to-purescript/tree/master/tut04)

You may find that the README for the next tutorial is under construction. But if you're an eager beaver and would like to look ahead, then most of the code samples from Brian's [videos](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) have been ported to PureScript already. But I may amend them as I write the accompanying tutorial markdown.  
