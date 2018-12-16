# Build curried functions

![series banner](../resources/glitched-abstract.jpg)

> *This is* **Tutorial 17** *in the series* **Make the leap from JavaScript to PureScript**. Be sure
> *to read the [series introduction](https://github.com/adkelley/javascript-to-purescript) where I cover the goals & outline, and the installation,*
> *compilation, & running of PureScript. I will be publishing a new tutorial approximately*
> *once-per-week. So come back often, there is a lot more to come!*

> [Index](https://github.com/adkelley/javascript-to-purescript/tree/master/index.md) | [<< Introduction](https://github.com/adkelley/javascript-to-purescript/blob/master/README.md) [< Tutorial 16](https://github.com/adkelley/javascript-to-purescript/tree/master/tut16) | [>> Tutorial 18](https://github.com/adkelley/javascript-to-purescript/tree/master/tut18)

In this tutorial, We're going to cover currying functions of multiple arguments.  The process of currying is to break down a function of multiple arguments into a set of nested functions; with each taking a single argument and returning a single result.  Think of it as decomposing the function into a chain of functions that have a single argument.  You'll find all the code examples in this tutorial, and supplementary ones in my [github repository](https://github.com/adkelley/javascript-to-purescript/tree/master/tut17).

The series outline and javascript code samples were borrowed with permission from the egghead.io course Professor Frisby Introduces Composable Functional JavaScript by Brian Lonsdorf - thank you, Brian! A fundamental assumption of each tutorial is that you've watched his [video](https://egghead.io/lessons/javascript-currying-with-examples) before tackling the equivalent PureScript abstraction featured in this tutorial. Brian covers the featured concepts extremely well, and I feel it's better that you understand its implementation in the comfort of JavaScript.

## Currying explained
In PureScript, like most functional programming languages, functions take only one argument and return one result by default. This approach models the [lambda calculus](https://en.wikipedia.org/wiki/Lambda_calculus), which is a notation for describing mathematical functions and programs.  Alonzo Church developed it in the 1930's, and it serves as a strong theoretical foundation for functional programming.

The way to accomplish this is by currying multiple function arguments. It is the process of turning a multi-argument function into a series of nested functions that each have one argument and return one result.  In the case of the last input argument, we return a result to the caller.  It means that an expression like `result = fn x y z` is transformed to `f1 = fn x`; `f2 = f1 y`; and `result = f2 z`.

When there are multiple arguments to a function, PureScript transcompiles it to JavaScript as a sequence of nested functions; very similar to the curried JavaScript code that Brian showed in his [video](https://egghead.io/lessons/javascript-currying-with-examples).  The main advantages to currying are 1) we can partially apply functions, and 2) we can create type signatures that are also functions.  

Partially applying a function means that we apply the function to some of its input arguments; while returning a function that's expecting the remaining arguments later on. Take the canonical example of `add10` shown below, which adds 10 to any number by partially applying the function, `myAdd` .  
```haskell
myAdd :: Int → Int → Int
myAdd x y = x + y

add10 :: Int → Int
add10 = myAdd 10
```
By supplying `myAdd` with the first argument of 10, `myAdd 10 y` is partially applied and executes only upon supplying the `y` argument.  Here we see that the main benefit of currying is the ability to create specialized functions, such as `add10`, without introducing new code or repetition.

```haskell
type Dict key value = key → Maybe value
```
Given the arguments `key` and `value`, we create the function type, ` key → Maybe value`.  You can think of it like a predicate that returns the `value` associated with `key`, assuming the `key` exists in the dictionary.  If it does, then return `Just value`; otherwise, return `Nothing`.

We create an empty dictionary with:
```haskell
emptyDict :: ∀ k v. Dict k v
emptyDict _ = Nothing
```
The type argument to `emptyDict` is a function type that initializes our dictionary.  It returns a function that ignores the input argument `k` and assigns our value to `Nothing`.  The insertion function for this dictionary is a little more interesting:
```haskell
insertDict :: (Eq k) => k → v → Dict k v → Dict k v
insertDict key value dict =
  \key' → if key == key'
            then (Just value)
            else dict key'
```
In `insertDict`, we are returning a function type that is partially applied.  The function is only fully applied after we supply it with the `key'` argument.  Upon which, it checks whether it matches with a `key` in the front of the dictionary.  If there is a match then return `Just value`; otherwise, delegate the function to the previous `Dict`, which was created by the previous call to `insertDict`.  Let's see how this works in the PureScript REPL.  

First, we fire up the REPL with the command `pulp --psc-package repl`.  Note that, by default, `pulp` assumes you're using [Bower](https://bower.io/)  to install your dependencies.  However, in my case, I chose the dependencies to be installed via the [psc-package manager](https://github.com/purescript/psc-package), and I inform `pulp` of this fact by adding the `--psc-package` flag. The REPL will re-compile your code and start the command line:

```haskell
> import Main
> :t  insertDict 'a' (1::Int) emptyDict
Char → Maybe Int
> (insertDict 'a' (1 :: Int) emptyDict) 'a'
(Just 1)
> insertDict 'b' 2 (insertDict 'a' (1::Int) emptyDict) 'b'
(Just 2)
> insertDict 'b' 2 (insertDict 'a' (1::Int) emptyDict) 'a'
(Just 1)
> insertDict 'b' 2 (insertDict 'a' (1::Int) emptyDict) 'x'
Nothing
```
Taking it from the top, we import our `Main`  module, and then we start running our tests.  Using the `:t` command, I often like to check my understanding of the type returned by a function. Thus, we see that `insertDict 'a' (1::Int) emptyDict` returns the function type `Char → Maybe Int`.  This result confirms our understanding - we must supply `key'` before `insertDict` is fully applied.  So, on the next command line, we assign `key'` to the character `a` which matches with `key`, and the output shows that it returns `Just 1` as expected.  

What happens when we supply a key that's not in the dictionary?  Well, on the second to last line, we see that the key `x` is not in the front of the dictionary, because `b → Just 2` is in front.  Therefore, we fall back to the previous `(insertDict 'a' (1::Int) emptyDict) ` and check again.  However it is not there either, so we fall back once more to `emptyDict` which returns `Nothing`.

Make no mistake - currying of multi-argument functions is not all unicorns and rainbows.  As you might imagine, this nesting of functions comes with a performance penalty which, in most cases, is worth the tradeoff in favor of partial function application.  However, in cases where there is performance critical code, we can declare a JavaScript function that takes multiple arguments simultaneously.

## In a pinch, use uncurried functions
Again, there is a performance penalty when currying multi-argument functions.  In these cases, PureScript provides a solution for writing functions whose speed you deem to be critical to the performance of your program.  The module `Data.Function.Uncurried` has an extensive number of type constructors that represent JavaScript functions that genuinely take multiple type arguments simultaneously.  For example:

```haskell
foreign import data Fn2 :: Type -> Type -> Type -> Type
```
Note that the first argument to `Fn2` is the name of the function you're calling.  The next two types are the input arguments, and the resulting type follows them.  Thus, if we felt that our canonical `myAdd` was a critical performance function (it's not), then we can transform it to the following:
```haskell
import Data.Function.Uncurried

myAddFast :: Fn2 Int Int Int
myAddFast = mkFn2 \x y -> x + y
```
PureScript will transcompile it to something similar to the following JavaScript code:
```javascript
exports.myAddFast = function(x, y) {
  return x + y;
};
```
Using the REPL again, we apply this function of two arguments by using the `runF2` function, giving us the expected result:

```haskell
> runFn2 myAddFast 10 10
20
```

## Summary
In this tutorial we learned that, in PureScript, all functions that have multiple arguments are curried by default.  When we curry a function of multiple arguments, we decompose it into a chained sequence of functions, each with one argument.  As we saw with the `add10` example, currying gives us the ability to create specialized functions from more general ones without introducing new code and repetition.  However, currying function arguments provoke a performance penalty.  Instead, for performance-critical code, there is a module `Data.Function.Uncurried` that you can leverage as an escape hatch.

I hope that you found the concept of currying to be easy to understand. In the next tutorial, we'll expand on our knowledge of functors by introducing applicative functors, which are described by the `Applicative` type class.  Applicative functors have many use cases, including form validation.   If you are enjoying these tutorials, then please help me to tell others by recommending this article and favoring it on social media. Thank you and until next time!

## Navigation
[<--](https://github.com/adkelley/javascript-to-purescript/tree/master/tut16) Tutorials [-->](https://github.com/adkelley/javascript-to-purescript/tree/master/tut18)

You may find that the README for the next tutorial is under construction. But if you're an eager beaver and would like to look ahead, then all the of code samples from Brian's [videos](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) have been ported to PureScript already. But I may amend them as I write the accompanying tutorial markdown.  
