# Make the Leap from Javascript to PureScript Series (DRAFT)

## 1.0 - Create linear data flow with container style types (Box)

This is the first tutorial in the series **Make the leap from Javascript to PureScript**.  Be sure to read the series [Introduction](https://github.com/adkelley/javascript-to-purescript), where you'll find the Javascript reference for learning the functional programming abstractions, but also how to install and run PureScript. The series outline and javascript code samples have been borrowed with permissino from the egghead.io course [Professor Frisby Introduces Composable Functional Javascript](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) by
[Brian Lonsdorf](https://github.com/DrBoolean). I assume that you've watched Brian's [video](https://egghead.io/lessons/javascript-linear-data-flow-with-container-style-types-box) and PureScript is up and running.  That is, you're already familiar with the **Box** abstraction and you're able to enter `bower update && pulp run` to load the library dependencies, compile the program, and run the code.  So let's go!

## Our first FP abstraction

Brian's video begins by showing a typical imperative approach to solving the problem of returning the next char from a number string:

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

What's wrong with this approach?  Well there's lots of variable assignment and consequently state that we need to keep track of in our mind.  What we want is to unify it all and compose it in one linear work flow, instead of separate lines with lots of assignment and state as we go along.

One approach is to bundle everything up into one expression.

```javascript
const nextCharForNumberString = str =>
  String.fromCharCode(parseInt(str.trim()) + 1)
```

You could even take this approach in PureScript or most other functional programming languages:

```haskell
nextCharForNumberString' :: String -> Char
nextCharForNumberString' str =
  fromCharCode(fromMaybe 0 (fromString(trim(str))) + 1)
```

The problem is that, while its one expression, its terribly hard to follow!  There is a better approach that we can borrow from our friend Array. Let's formally put our string into a box so that we can map over it.  In PureScript we would typically use the (`Identity` functor)[https://pursuit.purescript.org/packages/purescript-identity/2.0.0] for this purpose. Brian even mentions that it is the **identity functor**, but so that we don't scare everyone, let's create our own functor called **Box**

We do this in PureScript by creating our own type class:
```haskell
newtype Box a = Box a
instance functorBox :: Functor Box where
  map f (Box x) = Box (f x)
instance foldableBox :: Foldable Box where
  foldr f z (Box x) = f x z
  foldl f z (Box x) = f z x
  foldMap f (Box x) = f x
instance showBox :: Show a => Show (Box a) where
  show (Box a) = "Box(" <> show a <> ")"
```




## Diving into the code


## Navigation
[<--](https://github.com/adkelley/javascript-to-purescript) Tutorials [-->](https://github.com/adkelley/javascript-to-purescript/tree/master/tut02)

You may find that the README for the next tutorial is still under construction. Regardless, eager beavers are encouraged to look ahead. You'll find that all the of code samples from Brian's [videos](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) have been ported to PureScript already. But I reserve the right to amend them as I draft the accompanying tutorial markdown.  
