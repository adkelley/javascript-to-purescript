# Make the Leap from JavaScript to PureScript
# Tutorial 1 - Create linear data flow with container style types (Box)

This is the first tutorial in the series **Make the leap from JavaScript to PureScript**.  First, be sure to read the series [Introduction](https://github.com/adkelley/javascript-to-purescript), where the goals & outline, and the installation, compilation, & running of PureScript are covered.

The series outline and javascript code samples have been borrowed with permission from the egghead.io course [Professor Frisby Introduces Composable Functional JavaScript](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) by
[Brian Lonsdorf](https://github.com/DrBoolean) - thank you Brian! A fundamental assumption of each tutorial is that you've watched his video, because it covers the featured abstraction, and its better to understand its implementation in the comfort of familiar JavaScript.  For this tutorial, the abstraction is Box( ) covered in [video1](https://egghead.io/lessons/javascript-linear-data-flow-with-container-style-types-box). Box( ) is better known as the 'Identity' functor in swanky FP circles.  

So before we begin, I assume you're already familiar with the **Box** abstraction. You're also able to enter `bower update && pulp run` to load the library dependencies, compile the program, in order to run the PureScript code example.  Let's go!

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

What's wrong with that?  Well, there's lots of variable assignment and consequently lots of **state** that our feeble minds must track.  Wouldn't it be better to unify it all, by composing it into one linear work flow? Yes, of course it would!

So let's try bundling everything up into one expression:
```javascript
const nextCharForNumberString = str =>
  String.fromCharCode(parseInt(str.trim()) + 1)
```
Perhaps better, but its terribly hard to follow!  We must start with the inner most parenthesis, and work our way to the outer most, all while keeping track of the changes to `str`.  Good luck with that!

There is a much better approach that we can borrow from our dear old friend `Array`. Let's put our string into a box, so that we can map functions over it, just like we do with items in arrays and lists.  In PureScript, we typically use the `Identity` functor for this purpose, because it comes right out of the box (sorry - I couldn't resist the pun). But instead, let's create a new type called `Box`, so that we don't scare anyone away from our very first tutorial. Plus, we learn how to create new types in PureScript, which is a really nice way to express the meaning and context of our program!

## Time for PureScript

Now is a good time to open the code example [Main.purs](https://github.com/adkelley/javascript-to-purescript/tree/master/tut02/src/Main.purs) with your favorite code editor. If not already, you can refer to the [Introduction](https://github.com/adkelley/javascript-to-purescript) for a list of IDE plugins that will help to better format and view this PureScript code in your editor.  Let's look at the code's major components.

### Create a Box to hold the values

First, we create a new type `Box`:

```purescript
newtype Box a = Box a
```
In PureScript, when we want to give a new name to an existing type, we use the `newtype` constructor. In our case, this new type is `Box`, and it will contain the existing type `String` at the beginning of our composition.  But, just a few steps into our function composition, it will also need hold an `Int` (i.e., integer) type when we increment our unicode character number.  We handle this by declaring `newtype Box a = Box a`, instead of `newtype Box = Box String`, where `a` can be substituted by any type in our code.  See [NewTypes](https://leanpub.com/purescript/read#leanpub-auto-newtypes) from 'PureScript by Example' for more information.

Just as in our JavaScript example:
```javascript
const Box = x =>
({
  map: f => (f(x))
})
```
we must tell PureScript how to map over `Box`.  In PureScript, we simply declare that `Box` is an instance of the `Functor` class:
```purescript
instance functorBox :: Functor Box where
  map f (Box x) = Box (f x)
```
And, as in JavaScript, we also tell the PureScript compiler how to map over `Box`. Thus, whenever PureScript sees `map f (Box x)` it knows to take **x** out of the `Box`, apply the function **f**, and then put **x** back into the `Box`.

Next we should declare how to show the value of `Box` logging to the console.  In the JavaScript example, we did this by creating Box's prototype for `inspect`:
```javascript
const Box = x =>
({
  map: f => (f(x)),
  inspect: () => 'Box($(x))'
})
```
Similar to our `Functor` instance, we create an instance of the `Show` class in PureScript and tell it exactly how we want `Box` to be logged:
```purescript
instance showBox :: Show a => Show (Box a) where
  show (Box a) = "Box(" <> show a <> ")"
```
Note that the `<>` operator is a convenient infix operator alias for PureScript's string concatenation function `append`.

Finally, what to do with this Box? When we return the string, we don't actually want it to remain in our Box. To handle this in JavaScript, we add one more function to the `Box` called `fold`. It will remove it from the Box before we run the function(s) (e.g., `toLowerCase`), except it doesn't put it back in the Box.  First, again in JavaScript:
```javascript
const Box = x =>
({
  map: f => (f(x)),
  fold: f => f(x),
  inspect: () => 'Box($(x))'
})
```

Next, in PureScript, we declare `Box` to be 'foldable' by creating an instance of the `Foldable` class.  
```purescript
instance foldableBox :: Foldable Box where
  foldr f z (Box x) = f x z
  foldl f z (Box x) = f z x
  foldMap f (Box x) = f x
```
You can ignore `foldr` and `foldl` for now, because we don't need them to run the `nextCharForNumberString` function shown below. But by declaring the `Foldable` instance for `Box`, PureScript expects us define `foldr` and `foldl`, and so we did. Its `foldMap` that we care about, which tells PureScript how to take the element out of the Box, and apply a function **f** to it - just like the `fold` function declared in the JavaScript code below.

### Compose our functions

At last, we're ready to solve the problem of returning the next character from a given number string.  Just like our JavaScript example:
```javascript
const nextCharForNumberString = str =>
  Box[str]
  .map(s => s.trim())
  .map(s => new Number(s))
  .map(i => i + 1)
  .map(i => String.fromCharCode(i))
  .fold(c => c.toLowerCase())
```
we are going to use function composition in PureScript.  In both code samples, the result of each function is passed as the argument of the next, and the result of the last one is the result of the entire function.  Function composition is a fundamental construct in FP.  It makes it easier to understand the flow of our logic, and likely our code will be more readable and maintainable.

And without further ado, our PureScript reveal:
```purescript
1   nextCharForNumberString :: String -> String
2   nextCharForNumberString str =
3     Box str #
4     map trim #
5     map (\s -> fromMaybe 0 $ fromString s) #
6     map (\i -> i + 1) #
7     map (\i -> fromCharCode i) #
8     foldMap (\c -> singleton $ toLower c)
```
Let's look at the more interesting lines:
1.  We declare the function `nextCharForNumberString` and tell the PureScript compiler that it should expect a `String` as input, and return the transformed `String` as output.  Now JavaScript is a dynamically typed language and therefore we didn't and couldn't declare our `String` types. In contrast, PureScript is a statically typed language, which means that it (at compile time) will check to see if we've been asleep at the wheel.  For example, using a function argument or returning a value that is not our declared `String` type.  Now there's been a lot of debate on the advantages and disadvantages of dynamic vs. statically typed languages. I don't care to wax and wane over them, only to point out that JavaScript won't detect wrong argument types until you've actually run the program. It usually causes a runtime error, and perhaps this too late depending on where you weigh in on type ideology.  But with the introduction of [TypeScript](https://www.typescriptlang.org) from Microsoft and [Flow](https://flowtype.org) from Facebook, clearly there's is a greater awareness and interest by the JavaScript community for static type checking.  Nuff said!
2. Next we start the function application, assigning our input string to the variable name `str`
3. We put `str` into our `Box` so that we can map over it.  And 'look ma - no parenthesis!'.  PureScript uses white space to separate arguments, avoiding the need for parenthesis in cases where the order of the expression is clear. The `#` operator is similar to `.functionName()` in JavaScript or `|>` in Elm and Elixir.  It moves our transformed value along to the next function, placing it at the end of the argument list - very handy indeed!
4. Use `map` to take `str` out of the Box, and trim it using `trim` function.
5. Here's where things become very different from the JavaScript example.  Besides static type checking, many PureScript library functions have been written to help deal with possible runtime errors at the compiler stage.  Here, its possible that when we attempt to convert a number string (e.g., "1") to a number, `fromString` might have not have given an actual number (e.g., "this is not a number"). So, instead of ignoring the dire consequences, `fromString` returns a `Maybe String` type.  This serves as a clear signal to the programmer and the compiler that the possibility of a non-integer character must be dealt with. I won't get into the `Maybe` constructor just yet, because its too early in this series. But to deal with it, I decided to use the `fromMaybe` function that will convert the string to '0', if ever `fromString` detects that its been given a non-integer character by returning `Nothing`.  Finally the `$` operator is the reverse of `#`. It allows us to avoid placing parenthesis around `fromString s` - nice!
8. Now its time to fold 'em and go home.  We convert the character to lower case, then use `singleton` to convert our `Char` to our output type, `String`. `foldMap` applies these function expressions to the character in Box, and returns the transformed string to our `main` caller method covered in the next section.

### Call the function and log the result

Unless you're calling PureScript from JavaScript (yes you can do that), every PureScript application typically has a `main` method.  The `main` method is run after all the modules have been defined.  In our example, there is one module only - `Main` that imports several other modules listed at the top of the program (e.g., `import Data.Char (fromCharCode, toLower)`.  A `main` method is generated as a simple method call with no arguments.

From our `main` method we call our function `nextCharForNumberString` and log the result using the `log` or `logShow` functions.  The difference between these two is that `log` expects a string argument, whereas `logShow` can log a value, so long as an instance of the `Show` class has been declared. Here's the code:
```purescript
main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  log "Create Linear Data Flow with Container Style Types (Box)"

  log "All one expression bundled in parenthesis is difficult to follow"
  log $ nextCharForNumberString' "     64   "

  log "Let's borrow a trick from our friend array by putting string into a Box"
  log $ nextCharForNumberString "     64   "
```
You can safely ignore main's type declaration for now.  But it tells the compiler and anyone reading the program that `main` will generate a side effect, namely logging to the console. The rest should be self explanatory, with the exception of the special syntax called `do` notation. In simple terms (for now), `do` allows us to write our log statements as we would in an imperative program - one after the other.  Its much more powerful than that, especially when we encounter expressions that bind elements together, or give names to expressions using the `let` keyword.  But this explanation will suffice for now.

To run the program for the first time, `cd` into the `tut01/src` and type `bower update && pulp run`.  Then `pulp run` afterwards is enough.

### Miscellaneous but Important

Things I didn't cover that you may be wondering about:
1. You must import a module whenever you use one of its functions. Even the standard PureScript library called the 'Prelude' is not loaded automatically and therefore must be declared.
2. A PureScript directory structure is typically the following:
```
my-app/
  bower components/
  output/
  src/
  test/
  bower.json
```

## Navigation
[<--](https://github.com/adkelley/javascript-to-purescript) Tutorials [-->](https://github.com/adkelley/javascript-to-purescript/tree/master/tut02)

You may find that the README for the next tutorial is still under construction. Regardless, eager beavers are encouraged to look ahead. You'll find that all the of code samples from Brian's [videos](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) have been ported to PureScript already. But I reserve the right to amend them as I draft the accompanying tutorial markdown.  
