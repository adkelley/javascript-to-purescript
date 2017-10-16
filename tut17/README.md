# Make the Leap from Javascript to PureScript Series (DRAFT)

## 17 - xx

This is the second tutorial in the series **Make the leap from Javascript to PureScript**.  Be sure to read the series [Introduction](https://github.com/adkelley/javascript-to-purescript) where you'll find the Javascript reference for learning FP abstractions, but also how to install and run PureScript. The series outline and javascript code samples have been borrowed from the egghead.io course [Professor Frisby Introduces Composable Functional Javascript](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) by
[Brian Lonsdorf](https://github.com/DrBoolean). I assume that you've watched Brian's [video](https://egghead.io/lessons/javascript-linear-data-flow-with-container-style-types-box) and PureScript, together with Bower and Pulp have been installed.  That is you're familiar with the **Box** abstraction you're able to enter `bower update && pulp run` to load the library dependencies, compile the program, and run the code.  Let's go!

## Currying
In PureScript, like most FP languages, all functions take just one argument and return one result. This approach models the [lamda calculus](https://en.wikipedia.org/wiki/Lambda_calculus), which is a notation for describing mathematical functions and programs.  It was developed by Alonzo Church in the 1930's, and it serves as a strong theoretical foundation for functional programming.

So how does PureScript handle functions that take multiple arguments?  Well, just as we saw in the example above, when there are multiple arguments to a function, PureScript will transcompile it to JavaScript as a sequence of nested functions. Each will take one argument and return the next function or, in the case of the last one, return the final result.  This nesting of functions is called `currying`.

Let's take a simple example of a function that adds two arguments, starting with the PureScript code:
```purescript
add :: Int -> Int -> Int
add x y = x + y
```
Subsequently, PureScript will transcompile this to the following JavaScript code:
```javascript
var add = function (x) {
    return function(y)  {
         return x + y | 0
   }
}
```
The advantages of this approach include the ability to perform partial function application.  For example, using the `add` function above in the PureScript REPL:
```
> t add
Int -> Int -> Int

> add10 = add 10
> :t add10
Int -> Int

> add10 5
15
```
Now, if you suspect that there is a performance penalty to currying, then you are correct.  But PureScript provides a solution for writing functions whose speed you deem to be critical to the performance of your program.  The module `Data.Function.Uncurried` has an extensive number of type constructors (e.g., `Fn2`) that represent JavaScript functions that genuinely take multiple type arguments:
```haskell
foreign import data Fn2 :: Type -> Type -> Type -> Type
```
Note that the first argument is the function you're calling (remember functions are types too).  Thus if we felt that our canonical `add` was a critical performance function (it's not), then we can transform it to the following:
```haskell
import Data.Function.Uncurried

add :: Fn2 Int Int Int
add mkFn2 \x y -> x + y
```
PureScript will transcompile it to the following JavaScript code:
```javascript
exports.add = function(x, y) {
  return x + y;
};
```
Finally, running this in the PureScript REPL again
```
> runFn2 add 2 2
4
```

## Navigation
[<--](https://github.com/adkelley/javascript-to-purescript/tree/master/tut16) Tutorials [-->](https://github.com/adkelley/javascript-to-purescript/tree/master/tut18)

You may find that the README for the next tutorial is under construction. But if you're an eager beaver and would like to look ahead, then all the of code samples from Brian's [videos](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) have been ported to PureScript already. But I may amend them as I write the accompanying tutorial markdown.  
