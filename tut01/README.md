# Create linear data flow with container style types (Box)

![series banner](../resources/glitched-abstract.jpg)

> *Note: This is* **Tutorial 1** *in the series* **Make the leap from JavaScript to PureScript** *. Be sure*
> *to read the series introduction where I covered the goals & outline, and the installation,*
> *compilation, & running of PureScript. I’ll be publishing a new tutorial approximately*
> *once-per-week. So come back often, there’s a lot more to come!*

> [Index](https://github.com/adkelley/javascript-to-purescript/tree/master/index.md) | [< Introduction](https://github.com/adkelley/javascript-to-purescript) | [> Tutorial 2](https://github.com/adkelley/javascript-to-purescript/tree/master/tut02)

The series outline and javascript code samples were borrowed with permission from the egghead.io course [Professor Frisby Introduces Composable Functional JavaScript](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) by
[Brian Lonsdorf](https://github.com/DrBoolean) - thank you, Brian! A fundamental assumption of each tutorial is that you've watched his video already before tackling the abstraction in PureScript.  Brian teaches the featured abstraction extremely well and, assuming you’re a JavaScript programmer, I feel it's better to understand its implementation in the comfort of JavaScript.  For this tutorial, the abstraction is Box( ) covered in [video1](https://egghead.io/lessons/javascript-linear-data-flow-with-container-style-types-box). Note that the Box( ) abstraction is better known as the 'Identity' functor in swanky FP circles.  

One more time with feeling - You should be comfortable with the **Box** abstraction in JavaScript. You're also able to enter `bower update && pulp run` and `pulp run` after that, to load the library dependencies, compile the program, and run the PureScript code example.  **Finally**, if you read something that you feel could be explained better, or a code example that needs refactoring, then please let me know via a comment or pull request on [Github](https://github.com/adkelley/javascript-to-purescript/tree/master/tut01). Let's go!

## Baby's first FP abstraction - Box( )

Here's a typical imperative approach to transforming character strings:

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

What's wrong with it?  Well, there's lots of variable assignment and consequently lots of state that our feeble minds must track.  Wouldn't it be better to unify it all, by composing it into one linear workflow? Yes, of course!

So let's try bundling everything up into one expression:
```javascript
const nextCharForNumberString = str =>
  String.fromCharCode(parseInt(str.trim()) + 1)
```
Perhaps better, but it's terribly hard to follow!  We must start with the innermost parentheses, and work our way to the outermost, all while keeping track of the changes to `str`.  Good luck with that on more complex expressions!

There is a better approach that we can borrow from our dear old friend `Array`. Let's put our string into a box so that we can map our transform functions over it.  In PureScript, we typically use the `Identity` functor for this purpose, because it comes right out of the box (sorry - I couldn't resist the pun). But we don't scare anyone away from this very first tutorial, so instead let's build a new type called `Box`. Plus, we learn how to create new types in PureScript, which is a nice way to help express the meaning and context of our program!

## Time for PureScript

I’ve created a github repository with the markdown versions of these stories (i.e., README.md) together with the code samples. Now would be a good time to clone it from [here](https://github.com/adkelley/javascript-to-purescript) and you can [fetch upstream](https://help.github.com/articles/syncing-a-fork/) for future updates.

Navigate to tut01/src and open the code example [Main.purs](https://github.com/adkelley/javascript-to-purescript/tree/master/tut01/src/Main.purs) with your favorite code editor. If you don't have editor support for PureScript, refer to the [Introduction](https://github.com/adkelley/javascript-to-purescript) for a list of IDE plugins.  For now, you can ignore the module declaration and import list at the top.  Instead, let's start immediately on our Box declaration.

### Create a Box to hold the value

First, we create a new type `Box`:

```purescript
newtype Box a = Box a
```
In PureScript, when we want to give a new name to an existing type, we use the `newtype` constructor. In our case, this new type is `Box`, and it will contain the existing type `String` at the beginning of our composition.  But, just a few steps into our function composition, incrementing the Unicode character number requires that we hold an `Int` (i.e., integer) type also.  We handle this by declaring `newtype Box a = Box a`, instead of `newtype Box = Box String`, where `a` can be substituted by any type in our code.  See [NewTypes](https://leanpub.com/purescript/read#leanpub-auto-newtypes) from 'PureScript by Example' for more information.

Just as in our JavaScript example:
```javascript
const Box = x =>
({
  map: f => (f(x))
})
```
we must tell PureScript how to map over `Box`.  In PureScript, we declare that `Box` is an instance of the `Functor` class:
```purescript
instance functorBox :: Functor Box where
  map f (Box x) = Box (f x)
```
And, as in JavaScript, we also tell the PureScript compiler how to map over `Box`. Thus, whenever PureScript sees `map f (Box x)` then it's as easy as one-two-three:  
1. Take **x** out of the `Box`,
2. Apply the function **f**, and finally
3. Put **x** back into the `Box`.

Next, we should declare how to show the value of `Box` when logging to the console.  In our JavaScript example, we did this by creating Box's prototype for `inspect`:
```javascript
const Box = x =>
({
  map: f => Box(f(x)),
  inspect: () => 'Box($(x))'
})
```
Similar to our `Functor` instance, we create an instance of the `Show` class in PureScript and tell it exactly how we want `Box` to be logged to the console:
```purescript
instance showBox :: Show a => Show (Box a) where
  show (Box a) = "Box(" <> show a <> ")"
```
Note that the `<>` operator is a convenient infix operator alias for PureScript's string concatenation function `append`.

Finally, what to do with this Box? When we return the string, we don't want it to remain in our Box. To handle this in JavaScript, we add one more function to the `Box` called `fold`. It will remove it from the Box before we run the last function(s) before returning; except it doesn't put it back in the Box.  First, again in JavaScript:
```javascript
const Box = x =>
({
  map: f => Box(f(x)),
  fold: f => f(x),
  inspect: () => 'Box($(x))'
})
```

Next, in PureScript, we declare `Box` to be a comonad by creating an instance of the `CoMonad` class.  Comonads are like monads but wearing their category arrows backwards — forgive and forget I said that!

```purescript
instance extendBox :: Extend Box where
  extend f m = Box (f m)
instance comonadBox :: Comonad Box where
  extract (Box x) = x
```
You can ignore `extendBox`. Simply `comonadBox` needs it to do its magic. Otherwise, the compiler will complain if we don’t create an instance for it. Its `extract` we care about, and you should notice that the instance signature is a little different than `fold` from the javascript example. In particular, there’s no function application. So we’ll just use `map` to apply **f** on the values in `Box`, and `extract` to tell PureScript how to take the element out of the Box.

### Compose our functions

At last, we're ready to solve the problem of returning the next character from a given number string.  Just like our JavaScript example:
```javascript
const nextCharForNumberString = str =>
  Box(str)
  .map(s => s.trim())
  .map(s => new Number(s))
  .map(i => i + 1)
  .map(i => String.fromCharCode(i))
  .fold(c => c.toLowerCase())
```
we are going to use function composition in PureScript.  In both code samples, the result of each function is passed as the argument of the next, and the result of the last one is the result of the entire function.  Function composition is a fundamental construct in FP.  It makes it easier to understand the flow of our logic, and thus it's likely our code will be more readable and maintainable.

And without further ado, our PureScript reveal:
```purescript
1   nextCharForNumberString :: String -> String
2   nextCharForNumberString str =
3     Box str #
4     map trim #
5     map (\s -> fromMaybe 0 $ fromString s) #
6     map (\i -> i + 1) #
7     map (\i -> fromCharCode i) #
8     map (\c -> singleton $ toLower c) #
9     extract
```
Let's look at the more interesting lines:
1.  We declare the function `nextCharForNumberString` and tell the PureScript compiler that it should expect a `String` as input, and to return the transformed `String` as output.  Now JavaScript is a dynamically typed language, and therefore we didn't and couldn't declare our `String` types. In contrast, PureScript is a statically typed language, which means that it (at compile time) will check to see if we've been asleep at the wheel.  For example, using a function argument or returning a value that is not our declared `String` type.  

 Now there's been a lot of debate on the advantages and disadvantages of dynamic vs. statically typed languages. I don't care to wax and wane over them, only to point out that JavaScript won't detect wrong argument types until you've run the program. It might cause a runtime error, which is perhaps too late; depending on where you weigh in on ‘type ideology’.  But with the introduction of [TypeScript](https://www.typescriptlang.org) from Microsoft and [Flow](https://flowtype.org) from Facebook, clearly, there's a greater awareness and interest by the JavaScript community for static type checking.  Nuff said!

2. Next, we start the function application, assigning our input string to the variable name `str`.

3. We put `str` into our `Box` so that we can map over it.  And 'look ma - no parenthesis!'.  PureScript uses white space to separate arguments, avoiding the need for parenthesis in cases where the order of the expression is clear. The `#` operator is similar to `.functionName()` in JavaScript or `|>` in Elm and Elixir.  It moves our transformed value along to the next function, placing it at the end of the argument list - very handy indeed!

4. Use `map` to take `str` out of the Box, and trim it using `trim` function.

5. Here's where things become very different from the JavaScript example.  Besides static type checking, many PureScript library functions have been written to help deal with possible runtime errors, but at the compiler stage.  It is possible that when we attempt to convert a number string (e.g., "1") to a number, `fromString` might not have given an actual number (e.g., "this is not a number"). So, instead of ignoring the dire consequences, `fromString` returns a `Maybe String` type.  

 `Maybe String` serves as a clear signal to the programmer and the compiler that the possibility of a non-integer character, and you deal with it. I won't get into the `Maybe` constructor just yet because it is too early in this series. But to deal with it, I decided to use the `fromMaybe` function that will convert the string to '0', if ever `fromString` detects that it has been given a non-integer character by returning `Nothing`.  Finally, the `$` operator is the reverse of `#`. It allows us to avoid placing parenthesis around `fromString s` - nice!

8. Convert the character to lower case, then use `singleton` to convert our `Char` to our output type, `String`. Again, `map` applies these function expressions to the character in Box

9. Now it's time to fold 'em and go home. `extract` takes the value out of the Box and we return the transformed string to our `main` caller method covered in the next section.

### Call the function and log the result

Unless you're calling PureScript from JavaScript (yes you can do that), every PureScript application typically has a `main` method.  The `main` method runs after all the modules are defined.  In our example, there is one module only - `Main` that imports several other modules listed at the top of the program (e.g., `import Data.Char (fromCharCode, toLower)`.  A `main` method is a simple method call with no arguments.

From our `main` method we call our function `nextCharForNumberString` and log the result using the `log` or `logShow` functions.  The difference between these two is that `log` expects a string argument, whereas `logShow` can log a value, so long as an instance of the `Show` class has been declared. Here's the code:
```purescript
main :: Effect Unit
main = do
  log "Create Linear Data Flow with Container Style Types (Box)."

  log "Bundled parenthesis approach. All in one expression is suboptimal."
  log $ nextCharForNumberString' "     64   "

  log "Let's borrow a trick from our friend array by putting the string into a Box."
  log $ nextCharForNumberString "     64   "
```
You can safely ignore main's type declaration for now.  But it tells the compiler and anyone who is reading the program that `main` will generate a side effect, namely logging to the console. The rest should be self-explanatory, except the special syntax called `do` notation. In simple terms (for now), `do` allows us to write our log statements as we would in an imperative program - one after the other.  It's much more than that, especially when we encounter expressions that bind elements together or give names to expressions using the `let` keyword.  But this explanation will suffice for now.

To run the program for the first time, `cd` into the `tut01/src` and use my node package manager scripts by typing `npm run all`.  Then, afterward, typing `npm run exec` is enough. You can view (and modify) these scripts in the `package.json` file located in the root directory of each tutorial.

### Fun Facts

Some things I didn't cover that you may be wondering about:
1. Modules must be imported explicitly using the `import` statement, whenever you use one of its functions. Even the standard PureScript library called the 'Prelude' isn't loaded automatically.  Typically you will import all the functions from Prelude with `import Prelude`, while the imports from other modules are listed explicitly. This helps to avoid conflicting imports.

2. A PureScript directory structure is typically the following; which is created when you type `pulp --psc-package init` inside the root (i.e., my-app):
```
my-app/
  .psc-package/ (i.e., module dependencies) 
  output/
  src/
  test/
  bower.json
```

3. The transcompiled Javascript from this exercise is stored in `output/Main/index.js ` It's worth having a look and what got generated.  For example, our `newtype Box a = Box a` declaration is translated to:
```javascript
var Box = function (x) {
    return x;
};
```

4. If you want to run your code in the browser, then have a look at the command `pulp --psc-package browserify`.  The resulting Javascript code can be saved to a file and included in an HTML document. If you try this, you should see the log statements printed to your browser’s console.

5. Conversely, if you want to optimize your code, and run your code from the terminal, then use the commands `pulp --psc-package build -O --to output.js  && node output.js`.  

6. A recent compiler update introduced a new syntactic structure, called an operator section, for simplifying anonymous function arguments.  For example, on line 6 of `nextCharForNumberString` we wrote our increment by one function like this:
```purescript
map (\x -> x + 1)
```
Instead, using an operator section, we can save ourselves a few type strokes, and improve readability with this:
```purescript
map (_ + 1)
```
Hopefully, it's clear that the underscore represents the anonymous function argument **x**.

That's all, for now, folks!  See you in [Tutorial 2](https://github.com/adkelley/javascript-to-purescript/tree/master/tut02)

## Navigation

[< Introduction](https://github.com/adkelley/javascript-to-purescript) | [> Tutorial 2 ](https://github.com/adkelley/javascript-to-purescript/tree/master/tut02)

You may find that the README for subsequent tutorials are under construction. Most of the code samples from Brian's [videos](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) have been ported to PureScript already. Eager beavers are encouraged to look ahead, but I reserve the right to amend them as I write the accompanying tutorial.  
