# Series - Make the Leap from Javascript to PureScript (DRAFT)

## 1.0 - Create linear data flow with container style types (Box)

This is the first tutorial in the series **Make the leap from Javascript to PureScript**.  First, be sure to read the series [Introduction](https://github.com/adkelley/javascript-to-purescript), where the goals & outline, and the installation, compilation, & running of PureScript are covered.

The series outline and javascript code samples have been borrowed with permission from the egghead.io course [Professor Frisby Introduces Composable Functional Javascript](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) by
[Brian Lonsdorf](https://github.com/DrBoolean) - thank you Brian! Moreover a key assumption in each tutorial is that you've watched his video, which covers the featured abstraction, and understand how its implemented in the comfort of Javascript.  

For this tutorial its [video1](https://egghead.io/lessons/javascript-linear-data-flow-with-container-style-types-box) which covers the abstraction Box( ), better known as the 'Identity' value in FP circles.  In summary, I assume you're already familiar with the **Box** abstraction and you're able to enter `bower update && pulp run` to load the library dependencies, compile the program, and run the PureScript code examples.  Let's go!

## Baby's first FP abstraction - Box( )

Here's a typical imperative approach to solving a problem related to character strings:

```javascript
const nextCharForNumberString = str => {
  const trimmed = str.trim()
  const number = parseInt(trimmed)
  const nextNumber = number + 1
  return String.fromCharCode(nextNumber)
}

const result = nextCharForNumberString(' 64 ')

console.log(result)
```

What's wrong with that?  Well, there's lots of variable assignment and consequently **state** that's required to be kept track of in our feeble minds.  Wouldn't it be better to unify it all by composing it in one linear work flow? It should be better than separate lines with lots of assignment and associated state.

So let's try bundling everything up into one expression:
```javascript
const nextCharForNumberString = str =>
  String.fromCharCode(parseInt(str.trim()) + 1)
```

The problem is that, while its now all in one expression, its terribly hard to follow!  You must start with the inner most parenthesis, and work your way outwards while keeping track of all the changes to `str`.  

Fortunately, there is a better approach that we can borrow from our old friend `Array`. Let's put our string into a box so that we can map functions over it, just as we can with arrays.  In PureScript we would typically use the `Identity` functor for this purpose, because it comes right out of the box (no pun intended). But instead, let's create a new type called `Box`.  This way we won't scare the innocent; plus we learn how to create new types in PureScript!

## Dive into PureScript

Now is a good time to open our code example in your favorite code editor [Main.purs](https://github.com/adkelley/javascript-to-purescript/tree/master/tut02/src/Main.purs) in the `tut01/src` directory. You can refer to the [Introduction](https://github.com/adkelley/javascript-to-purescript) for a list of IDE plugins that help to format PureScript code.  Let's look at the code's major components.

### Create a Box to hold our values

First, we create our new type `Box`:

```purescript
newtype Box a = Box a
```
In PureScript, when we want to give a new name to an existing type, we use the `newtype` constructor. Note that `newtypes` must define exactly one constructor, and that constructor must take exactly one argument. In our case, the name is `Box` which will contain the existing type `String` at the beginning of our composition.  But it will later hold a `Number`, just a few steps into our function composition; when we increment our unicode character number by one.  We handle this by declaring `Box a`, where `a` can be substituted by any type in our code.  See [NewTypes](https://leanpub.com/purescript/read#leanpub-auto-newtypes) in 'PureScript by Example' for more information.

Just as in the Javascript example:
```javascript
const Box = x =>
({
  map: f => (f(x))
})
```
we tell PureScript how to map over `Box`.  In PureScript, we simply declare that `Box` is an instance of the `Functor` class:
```purescript
instance functorBox :: Functor Box where
  map f (Box x) = Box (f x)
```
And, as in Javascript, we also tell PureScript how to map over `Box`. Thus, whenever PureScript sees `map f (Box x)` it knows to apply the function **f** to **x** and put it back into `Box`.

Next we should declare how to show the value of `Box` in the console.  In the Javascript example, Brian created Box's prototype for `inspect`:
```javascript
const Box = x =>
({
  map: f => (f(x)),
  inspect: () => 'Box($(x))'
})
```
Similar to how we created a `Functor` instance, in PureScript we'll create an instance of the `Show` class:
```purescript
instance showBox :: Show a => Show (Box a) where
  show (Box a) = "Box(" <> show a <> ")"
```
Note that the `<>` operator in the above example is a convenient infix alias for PureScript's string concatenation function `append`.

Finally, what to do with this Box? When we return the character, we don't actually want it in our Box. In Javascript we add one more function to `Box` called `fold`. What this will do is remove it from the Box before we run the functions (e.g., map), except it doesn't put it back in the Box.  Once again in Javascript:
```javascript
const Box = x =>
({
  map: f => (f(x)),
  fold: f => f(x),
  inspect: () => 'Box($(x))'
})
```

In PureScript we declare `Box` to be 'foldable' by creating an instance of the `Foldable` class.  
```purescript
instance foldableBox :: Foldable Box where
  foldr f z (Box x) = f x z
  foldl f z (Box x) = f z x
  foldMap f (Box x) = f x
```
You can ignore `foldr` and `foldl` for now, because we don't need them to run `nextCharForNumberString`. But by declaring the `Foldable` instance for `Box`, PureScript expects us define them, and so we did. Its `foldMap` that we care about, which tells how to take the element out of the Box, and apply the function **f** to it - just like the `fold` function declared in Javascript.

### Compose our functions

At last, we're ready to solve the problem of returning the next character from a number string (i.e., `nextCharForNumberString`).  Like our Javascript example:
```javascript
const nextCharForNumberString = str =>
  Box[str]
  .map(s => s.trim())
  .map(s => new Number(s))
  .map(i => i + 1)
  .map(i => String.fromCharCode(i))
  .fold(c => c.toLowerCase())
```
we are going to use function composition.  Here the result of each function is passed as the argument of the next, and the result of the last one is the result of the entire function.  Function composition is a fundamental technique in FP.  It makes it easy to understand the flow of our logic, and therefore our code is more readable and maintainable.

And now for our PureScript reveal:
```purescript
1   nextCharForNumberString :: String -> String
2   nextCharForNumberString str =
3     (Box str) #
4     map trim #
5     map (\s -> fromMaybe 0 $ fromString s) #
6     map (\i -> i + 1) #
7     map (\i -> fromCharCode i) #
8     foldMap (\c -> singleton $ toLower c)
```
Let's look at the more interesting lines:
1.  We declare the function `nextCharForNumberString` and tell PureScript that we're expecting a `String` as input, and will return the transformed `String` as output.  Now Javascript is dynamically typed language and therefore we didn't and couldn't declare our types. In contrast, PureScript is a statically typed language, which means the PureScript compiler is going to check (at compile time) to see if we've been asleep at the wheel.  For example, sending something other than `String` to the function, or attempting to use a function in the composition that doesn't work on `String`.  Now there's been a lot of debate on dynamic vs. statically typed languages, and I don't care to wax and wane over the advantages and disadvantages. But clearly, with the introduction of [TypeScript](https://www.typescriptlang.org) from Microsoft, and [Flow](https://flowtype.org) from Facebook, there's been greater interest by the Javascript community to add static checking in order to help scale Javascript applications. Nuff said!
2. Next we declare our function expressions and give our input `String` the name `str`
3. We put `str` into our `Box` so that we can map over it.  The `#` operator is similar to `.functionName()` in JavaScript or `|>` in Elm and Elixir.  It moves our transformed value along to the next function, placing it at the end of its argument list - very handy indeed!
4. Use `map` to take `str` out of the Box and trim it using `trim` function.  And 'look ma - no parenthesis!'.  PureScript uses white space to separate the arguments, avoiding the addition of parenthesis in cases where the computation order is clear.
5. Here's where things become very different from Javascript.  PureScript helps you to deal with possible runtime errors at the compiler stage.  Here, its possible that when we attempt to convert a number string (e.g., "1") to a number, we might not have given `fromString` an actual number (e.g., "this is not a number"). So, instead, PureScript returns a `Maybe String` type that signals to the programmer that they need to deal with the possibility of a non-integer character. I won't get into the `Maybe` constructor so early on in this series. But in order to deal with it, I decided to use the `fromMaybe` function that will convert the string to '0' whenever `fromString` is given the wrong input.  Finally the `$` allows us to avoid placing parenthesis around `fromString s` - nice!
8. Now its time to fold 'em and go home.  We convert the character to lower case, then use `singleton` to convert our `Char` to our output type, `String`. Then, `foldMap` applies these two functions and returns the transformed string to our caller `main`

### Call nextCharForNumberString and log to the console
Every Pu


## Navigation
[<--](https://github.com/adkelley/javascript-to-purescript) Tutorials [-->](https://github.com/adkelley/javascript-to-purescript/tree/master/tut02)

You may find that the README for the next tutorial is still under construction. Regardless, eager beavers are encouraged to look ahead. You'll find that all the of code samples from Brian's [videos](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) have been ported to PureScript already. But I reserve the right to amend them as I draft the accompanying tutorial markdown.  
