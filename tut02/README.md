# Refactor imperative code to a single composed expression using Box

![series banner](../resources/glitched-abstract.jpg)

> *Note: This is* **Tutorial 2** *in the series* **Make the leap from JavaScript to PureScript** *. Be sure*
> *to read the series introduction where we cover the goals & outline, and the installation,*
> *compilation, & running of PureScript. I’ll be publishing a new tutorial approximately*
> *once-per-week. So come back often, there’s a lot more to come!*

> [<< Introduction](https://github.com/adkelley/javascript-to-purescript) [< Tutorial 1](https://github.com/adkelley/javascript-to-purescript/tree/master/tut01) | [> Tutorial 3](https://github.com/adkelley/javascript-to-purescript/tree/master/tut03)

The series outline and javascript code samples were borrowed with permission from the egghead.io course [Professor Frisby Introduces Composable Functional JavaScript](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) by
[Brian Lonsdorf](https://github.com/DrBoolean) - thank you, Brian! A fundamental assumption of each tutorial is that you've watched his video before tackling the abstraction in PureScript.  Brian covers the featured concepts extremely well, and I feel it's better that you understand its implementation in the comfort of JavaScript.  For this tutorial, we're going to look at another example of the abstraction `Box( )` (see [video2](https://egghead.io/lessons/javascript-refactoring-imperative-code-to-a-single-composed-expression-using-box))

One more time with feeling - You should be already somewhat familiar with the **Box** abstraction. You're also able to enter `bower update && pulp run` and `pulp run` after that, to load the library dependencies, compile the program, and run the PureScript code example.  Finally, if you read something that you feel could be explained better, or a code example that needs refactoring, then please let me know via a comment or send me a pull request on [Github](https://github.com/adkelley/javascript-to-purescript/tree/master/tut02). Let's go!

## Rewind - function composition with ordinary functions

Before we cover this week's code example, let's step back for a moment to talk more about function composition.  While Brian covered it in his [video1](https://egghead.io/lessons/javascript-linear-data-flow-with-container-style-types-box), there’s been good feedback that I glossed over it in Tutorial 1.  So here goes:

You should be asking “why is mapping over Box better than using ordinary functions (a -> b)?” Well, it's not always better because ordinary functions are simpler to read, write, use, and you can reason about their behavior more quickly. For example, it is easier to do the following in PureScript:
```
   function x    = foo $ bar $ baz $ quux $ x
   or function x = foo <<< bar <<< baz <<< quux $ x
   or function x = (quux >>> baz >>> bar >>> foo) x
```
Apply ($), backward composition (<<<), or forward composition (>>>) - they all return the same result. So choose which ever is easier for you to understand.  

Now, using composition on ordinary functions, let’s refactor `nextCharForNumberString` from [tut01/src/Main.purs](https://github.com/adkelley/javascript-to-purescript/blob/master/tut01/src/Main.purs).  I chose forward composition (>>>) because I prefer showing long transformation chains starting with the first transformation. I'll often put them on separate lines to make them more readable, and I prefer [pointfree](https://wiki.haskell.org/Pointfree) style (i.e., not mentioning the argument `str`) whenever possible.

```purescript
nextCharForNumberString :: String -> String
nextCharForNumberString  =
  trim >>>
  fromString >>>
  fromMaybe 0 >>>
  (+) 1 >>>
  fromCharCode >>>
  singleton
```

Where Functors shine is when you’re mixing categories, and you need a bridge from one category to the other.  First, what is a category?  Well, we’ve seen two categories already from Tutorial 1.  `Box` is a category and `Maybe` is another, and each contains our transformed values at some point during the transformation chain.  If you recall, we passed the value from `Maybe` back into `Box` by using the `fromMaybe` function.  Still, using `Box` and its instances `map` and `fold` is contrived because `nextCharForNumberString` composes just fine using ordinary functions.

But in the wild, you’ll often be mixing several categories, and thus you’ll likely need to provide an adaptor layer that transforms another category to yours or vice-versa.  Functors help you to write this adaptor layer, but we’re not quite ready to show how.  We just need a few more tools in our toolbox, so I’ll come back to this topic later in the tutorial series.

## Taking Box out for another spin

Our Tutorial 2 code example solves the simple problem of computing a discount, given money and
percentage strings.  We’re going to use our Box functor again from Tutorial 1, but it would've been perfectly okay to use ordinary function composition. Since our objective is to learn the Box functor, let’s take it out for another spin.

### Where did our Box declaration go?

You might be wondering what happened to our `Box` Class and instances from Tutorial 1, or why aren't they declared in `Main.purs`.  Well, Box is all safe and warm, tucked away in [tut02/src/Data/Box.purs](https://github.com/adkelley/javascript-to-purescript/blob/master/tut02/src/Data/Box.purs). We're going to be using Box in several tutorials, so its best to create a module for it and park it somewhere permanent.  In idiomatic PureScript (and Haskell) you'll see type constructors (e.g., List) and functions for working with these constructors in `src/Data`. Then, just import the module (i.e., `import Data.Box (Box(..)`) as you would any other module when you need to call the constructor and its functions.  I've added a couple more instance declarations to `Box.purs`, but you can ignore them as we'll be sticking with `map`, `show` and `extract` for now.

### Convert the money string to float

First, showing `moneyToFloat` in JavaScript followed by PureScript:
 ```javascript
const moneyToFloat = str =>
     Box(str)
     .map(s => s.replace(/\$/g, ''))
      .map(r => parseFloat(r))
```
The PureScript example below is much more interesting:
```purescript
moneyToFloat :: String -> Box Number
moneyToFloat str =
    Box str #
    map (replace (Pattern "$") (Replacement "")) #
    map (\replaced -> unsafeParseFloat replaced)
```

In the `replace` function, notice the constructor
`Pattern`, which is used by the `purescript-strings` module to match our substring.  I chose to use a substring rather than a regular expression just to keep it simple.  It's a viable solution because there should only be one dollar sign in the currency string. Our new substring “” is wrapped in a`Replacement` constructor which specifies a replacement for our pattern.  You can check out [Pursuit](https://pursuit.purescript.org) for more information on these two constructors.

Let’s move on to `unsafeParseFloat` on the last line.  It's our first encounter with PureScript’s FFI capabilities which I partially cover in **Calling JavaScript from PureScript** in the next section below. In JavaScript’s `parseFloat` function, invalid number strings return, `NaN`.  But we told the type system that we’re always returning a `Number` - ouch!  We can't return `NaN` without warning the user because that’s not how we roll in PureScript. We must deal with it - no excuses!

In production, returning a `Maybe` or `Either` constructor here would be two good choices, so that the type signature makes it clear that the user must deal with the possibility of `NaN`.  We’ll cover both of these in detail in future tutorials. To avoid conflating the example with these abstractions, I chose to create `unsafeParseFloat`  (see [Main.js](https://github.com/adkelley/javascript-to-purescript/blob/master/tut02/src/Main.js)).  Here's why:

In PureScript and other functional languages, it's a common idiom to designate functions as either `safe` or
`unsafe` whenever there’s the possibility of side effects, such as exceptions. For example, you might create the foreign declaration `unsafeHead` which returns the head of an array. And to deal with the possibility of calling `unsafeHead` on an empty array, you can decide to throw an error exception.  Therefore designating it with the `unsafe` prefix warns the user that they should ensure that they never call `unsafeHead` with an empty array.

### Convert the discount string to a number

Next up is `percentToFloat` which is nothing new, with one exception.  We can start immediately with a `Box` of  `str.replace(/\%/g, ''))`.  It means that in practice we don't have put a value in the box first before applying our first transformation function.  It just comes down to your preference for readability and performance.

```javascript
const percentToFloat = str =>
     Box(str.replace(/\%/g, ''))
     .map(replaced => parseFloat(replaced))
     .map(number => number * 0.01)
```
Now the equivalent in PureScript.  Again, nothing new here,
other than what was described above.

```purescript
percentToFloat :: String -> Box Number
percentToFloat str =
    Box (replace (Pattern "%") (Replacement "") str) #
    map (\replaced -> unsafeParseFloat replaced) #
    map (_ * 0.01)
```

### And take it home with applyDiscount

Both the JavaScript and PureScript code samples below are excellent examples of using nested closures to compute `cost` and `savings` for use within the final expression.  But the big
‘ah-ha moment’ is that we use `fold` instead of `map` before applying the final expression.  Had
we used `map` on each instead of `fold`, the result would’ve
been two boxes deep `Box ( Box ( x ) )`.  Plus there’s no type checker in JavaScript, and so you might’ve gone mapping your merry way into possibly hours of debugging.  I’m not sure whether [TypeScript](https://www.typescriptlang.org) or [Flow](https://flow.org) type checkers would catch this problem.  You can try it, but I doubt it.

```javascript
const applyDiscount = (price, discount) =>
     Box(moneyToFloat(price))
     .fold(cost =>
       percentToFloat(discount)
        .fold(savings =>
          cost - cost * savings))
 ```

Now, in contrast to JavaScript, here where’s the PureScript compiler can save you hours of frustration.  If you try using `map` instead of `extract`, the compiler will raise an error message, seeing as you’re calling `percentToFloat` with a `Box String` instead of `String`.  That’s the beauty of an intelligent type checker!  I encourage you to go ahead and try this yourself so that you become familiar with PureScript's compiler error messages.  Again, from [Tutorial 1](https://github.com/adkelley/javascript-to-purescript/blob/master/tut01/src/Main.js), be aware that `extract` is different than `fold` from the JavaScript example above.  The instance `extract` does not apply a function before taking the value out of the box.  That’s why I’ve got `extract` as a function of the string transformations, and its tucked inside parenthesis instead of chaining.  

```purescript
applyDiscount :: String -> String -> Number
applyDiscount price discount =
  (extract $ moneyToFloat price) #
  (\cost -> (extract $ percentToFloat discount) #
    (\savings -> cost - cost * savings))
```

One final note: besides using ordinary function composition
(see **Function Composition with ordinary functions** above), there’s a more canonical approach to writing `applyDiscount`.  So for those of you who like to see what’s in store for my future tutorials, I’ve included this canonical pattern as a bonus example in the [code](https://github.com/adkelley/javascript-to-purescript/blob/master/tut02/src/Main.purs).  

## Calling JavaScript from PureScript

This tutorial would not be complete without spending a little
more time on PureScript’s _foreign function interface_ (or FFI).
It simple terms, the FFI enables communication to and from
JavaScript, so that we can take advantage of the vast number of JavaScript libraries that are already available.  This topic is covered very well in Phil Freeman’s [PureScript made Easy](https://leanpub.com/purescript/read#leanpub-auto-the-foreign-function-interface) (free to read online), so I highly recommend you read his chapter on it. But if it's TL;DR time again, then I’ve covered calling JavaScript from PureScript below, using `safeParseFloat` as the example.

From PureScript, to call an existing JavaScript function, we create a foreign import declaration in `Main.purs`:

```purescript
foreign import unsafeParseFloat :: String -> Number
```

We also need to write a foreign Javascript module, in our case [Main.js](https://github.com/adkelley/javascript-to-purescript/blob/master/tut02/src/Main.js):

```javascript
”use strict”;

exports.unsafeParseFloat = parseFloat;
```

Pulp will find `.js` files in the src directory and provide them
to the compiler as foreign Javascript modules.  By convention, I
called it Main.js as a signal to the user that I've defined the foreign declaration for unsafeParseFloat in Main.purs.

I hope you appreciate the simplicity of PureScripts FFI.  I
believe it's a real advantage over other FFI implementations such as [ports in Elm](https://guide.elm-lang.org/interop/javascript.html).


That's all for Tutorial 2.  Until next time!

## Navigation
[<< Introduction](https://github.com/adkelley/javascript-to-purescript) [< Tutorial 1](https://github.com/adkelley/javascript-to-purescript/tree/master/tut01) | [> Tutorial 3 ](https://github.com/adkelley/javascript-to-purescript/tree/master/tut03)
