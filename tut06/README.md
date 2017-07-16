# Create types with Semigroups (DRAFT)

![series banner](../resources/glitched-abstract.jpg)

> *Note: This is* **Tutorial 6** *in the series* **Make the leap from JavaScript to PureScript** *. Be sure*
> *to read the series introduction where I cover the goals & outline, and the installation,*
> *compilation, & running of PureScript. I will be publishing a new tutorial approximately*
> *once-per-week. So come back often, there is a lot more to come!*

> [<< Introduction](https://github.com/adkelley/javascript-to-purescript) [< Tutorial 5](https://github.com/adkelley/javascript-to-purescript/tree/master/tut05)

Welcome to Tutorial 6 in the series **Make the leap from Javascript to PureScript**.  I hope you've enjoyed the learnings thus far.  Be sure to read the series [Introduction](https://github.com/adkelley/javascript-to-purescript) to learn how to install and run PureScript. I borrowed (with permission) this series outline and javascript code samples from the egghead.io course [Professor Frisby Introduces Composable Functional JavaScript](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) by
[Brian Lonsdorf](https://github.com/DrBoolean) - thank you, Brian! A fundamental assumption is that you have watched his [video](https://egghead.io/lessons/javascript-combining-things-with-semigroups) before tackling the equivalent PureScript abstraction featured in this tutorial.  Brian covers the featured concepts extremely well, and it's better that you understand its implementation in the comfort of JavaScript.

All of the code examples and the markdown for this article are on [Github](https://github.com/adkelley/javascript-to-purescript/tree/master/tut06).  If you read something that you feel could be explained better, or a code example that needs refactoring, then please let me know via a comment or send me a pull request.  Finally, If you are enjoying this series then please help me to tell others by recommending this article and/or favoring it on social media

## Symbols, Operations & Laws - Oh My!

I must admit that writing this tutorial was difficult at first.  I kept wondering whether I might turn some readers off by making a definitive connection between programming languages and mathematics.   Why?  Well, there seems to be this meme going around that programming is not math; that you don't need math to program.

For example, I saw a recent tweet related to learning PureScript where the poster asked, as a thought experiment, whether it would be better to promote a simpler PureScript by ditching the category theory.   For example, rename the categories to something more user-friendly, like `Monoid => AssociativeConcattableWithIdentity`.  I believe this kind of thinking is wrong!  If we don't embrace math in programming, then we are denying the most powerful tool for understanding what we are doing.  

Instead, we need to do a whole lot better in explaining the connection between programming languages and mathematics.  Fortunately, from time to time, someone gets it right by teaching it simply so that virtually anyone who wants to learn, can learn. And when they do, we should be promoting these people by singing their praises from the highest mountains.  So here's my nominee for the "Make it simple but not simpler" hall of fame. His name is Chris Taylor @cmtaylor, and he gave an excellent talk titled "[The Algebra of Algebraic Data Types](https://www.youtube.com/watch?v=YScIPA8RbVE)."  If you haven't seen his talk, then you should set my tutorial aside for a moment and watch it.

In his talk, he explains that programming languages form an algebra, not unlike the algebra we learned in school.  We learned that symbols are 0, 1, 2, x, y, z, etc.; operations are +, -, \*, ÷, etc.; and laws are 0 + x = x, etc.  So how does this translate to PureScript?  Well, in PureScript the types are an algebra.  The symbols are the types themselves (Int, Boolean, String, etc.).  The operations are the type constructors (Maybe, Either, etc.).  And the laws . . . , well I don't know what all the laws are for the PureScript algebra.  But, we can certainly look at smaller subsets of the language, which is my long and winded way of introducing the topic of this tutorial - Semigroups!

## Semigroups come from abstract algebra

Are you still with me?  To reiterate what I wrote in my introduction, don't let this, or any other mathematical name, scare you from learning functional programming.  If we keep the names (e.g., Semigroup), then we benefit from a whole lot of information derived from the mathematics, namely the types and their laws!  If we understand the types (i.e., list, string, int, etc.) and their laws (e.g., associativity, identity, etc.), then it helps us tremedously to reason about our program.   

A Semigroup is a type together with a binary operation `<>` that satisfies the associativity law.  If we unpack this definition further - a binary operation takes two elements from our type and produces another element of the same type.  Moreover, if you think long enough, you'll see that a binary operation is just a method of function composition.  I like to think of binary operations like concatenation, where we mash two objects together to get a third object.  In PureScript, this is called `append`, with  `(<>)` as its infix operator.  Note that Brian uses `concat` in his examples but, to help reduce cognitive load, I'll use `append` in both JavaScript and PureScript.

Good examples of `<>` on Semigroups include addition, multiplication.  The associativity law states that given elements a, b and c from our type, then `a <> (b <> c) = (a <> b) <> c`.  Notice I didn't include subtraction!  It is not a Semigroup because it doesn't satisfy the associativity law.  Meaning, `a - (b - c)` is not equal to `(a - b) - c`.   The string type and its binary operation of append is another good example of a Semigroup.   Checking whether the associativity law holds, we find that `("foo" <> "bar") <> "baz"` is equal to `"foobarbaz"` and `"foo" <> ("bar" <> "baz")` is also equal to `"foobarbaz"`.

Simple, right?  I hope you're now wondering what all the fuss is about.  So with that out of the way, I believe we're ready to present the PureScript equivalents to the JavaScript code snippets from Brian's [tutorial](https://egghead.io/lessons/javascript-combining-things-with-semigroups).

## Examples of Types with Semigroups

Let's stick with append as our binary operation or method of function composition (whichever you like) for the following examples.  Below, we create our first type constructor `Sum` that takes two elements of the same type and adds them together to create another element of the same type.  

### Sum
```javascript
const Sum = x =>
({
  x,
  append: ({ x: y }) =>
    Sum(x + y),
  inspect: () =>
    'Sum(${x})'
})

const res1 = Sum(1).append(Sum(2)) // Sum(3)
```

```haskell
newtype Sum a = Sum a
instance showSum :: Show a => Show (Sum a) where
  show (Sum x) = "(Sum " <> show x <> ")"
instance semigroupSum :: Semiring a => Semigroup (Sum a) where
  append (Sum a) (Sum b) = Sum (a + b)
derive newtype instance eqSum :: Eq a => Eq (Sum a)  

main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  log "Integers:"
  logShow $ (Sum 1 <> Sum 2) <> Sum 3  -- (Sum 6)
  log "Associativity law:"
  logShow $ (Sum 1 <> Sum 2) <> Sum 3 == Sum 1 <> (Sum 2 <> Sum 3)  -- true
```

In his [tutorial](https://egghead.io/lessons/javascript-combining-things-with-semigroups) on Semigroups, Brian uses deconstruction in `Sum`'s append method to expose the other sum `y`.  If you're not clear about the JavaScript code example, then please review his tutorial. More interesting (yes, I'm biased) is the PureScript example.  We define our newtype constructor `Sum` and the three type class instances that we use to show, append and prove associativity.  I covered newtype constructors in my very [first tutorial](https://github.com/adkelley/javascript-to-purescript/tree/master/tut01/src/README.md).  But to elaborate further, they are a special case of [algebraic data types](https://leanpub.com/purescript/read#leanpub-auto-algebraic-data-types) that define one constructor only, and that constructor must take exactly one argument.  In this example, `Sum` is the constructor,  and its one argument is the [generic](https://en.wikipedia.org/wiki/Generic_programming#Genericity_in_Haskell) type `a`.  I chose a generic type because we can add multiple types of numbers, like integers, floats, and natural numbers. Next, we define our instance declarations.

First up is the `Show` type class, which tells the PureScript compiler how we want to display our results.  Using type deconstruction, we extract the value from the constructor.  Next, is our `Semigroup` which declares addition as our operation for mashing two type elements together to derive our third element. Also, I introduced a type class constraint that we haven't seen until now - `Semiring`.  Here again, PureScript uses a well-defined term from abstract algebra that describes type elements that you can add or multiply together.  And finally, there is the matter of associativity.  To prove that `Sum` is associative, I derive an instance of the `Eq` type class (i.e., equality) to show in my examples that the left and right sides of my expression are equal.  That is, `(Sum 1 <> Sum 2) <> Sum 3 == Sum 1 <> (Sum 2 <> Sum 3)`.

### All

This next Semigroup allows us to mash two boolean types together to get a third boolean -- `true && false = false`.  But, when creating a custom Semigroup constructor, make sure you check the associativity law. Well, `(true && false) && true == true && (false && true)`, so I think we are onto something.  Let's define our next Semigroup type constructor using booleans and call it `All`.

```javascript
const All = x =>
({
  x,
  concat: ({x: y}) =>
    All(x && y),   
  inspect: () =>        
    'All(${x})'
})

const res = All(true).concat(All(false))  // All(false)
```

```haskell
newtype All a = All a
instance showAll :: Show a => Show (All a) where
  show (All x) = "(All " <> show x <> ")"
instance semigroupAll :: BooleanAlgebra a => Semigroup (All a) where
  append (All a) (All b) = All (a && b)
derive instance eqAll :: Eq a => Eq (All a)

main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  logShow $ All true <> All false -- (All false)
  log "Associativity law:"
  logShow $ (All true <> All true) <> All true == All true <> (All true <> All true) -- true
```

There's not much difference between the `All` and `Sum` newtypes and their instance declarations. But if you are lost, then read the `Sum` section again and don't hesitate to leave a question in the comments.  We merely swapped out numbers for booleans, and our append operation has become `&&` instead of `+`.  Though, there is that new type class constraint `BooleanAlgebra`.  Well, it's just another math term to describe types that behave like boolean values.   I'm down for getting easy wins and, compared to Semigroup and Semiring, I believe BooleanAlgebra is much easier to remember.

### First

And finally, let's make a somewhat odd Semigroup that we'll call `First`.  Remember that Strings are a Semigroup where `"a" <> "b" <> "c" = "abc"`.  But what if our append operation was structured to retain only the first argument?  That is `First "a" <> First "b" <> First "c" = First "a"`.  Does that still constitute a Semigroup?  Let's check it by applying the associativity law - `(First "a" <> First "b") <> First "c" == (First "a" <> First "b") <> First "c" == First "a"`.  Yes, me thinks we have a `Semigroup`, so let's code it up.

```javascript
const First = x =>
({
   x,
   concat: _ =>
     First(x),
   inspect: () =>
     'First(${x})'
})

const res = First("a").concat(First("b")).concat(First("c")) // First("a")
```

```haskell
newtype First a = First a
instance showFirst :: Show a => Show (First a) where
  show (First x) = "(First " <> show x <> ")"
instance semigroupFirst :: Semigroup (First a) where
  append (First a) _ = (First a)
derive instance eqFirst :: Eq a => Eq (First a)  

main :: forall e. Eff (console :: CONSOLE | e) Unit
main =
  logShow $ First "a" <> (First "b" <> First "c") -- (First "a")
  log "Associativity law:"
  logShow $ (First "a" <> First "b") <> First "c" == First "a" <> (First "b" <> First "c")  -- true
```

Here again, there's not much difference between `First` and `Sum` newtype and instance declarations.  We merely swapped out numbers for a generic type, be it a string, number, or pick your poison.  And our append operation ignores every argument except for the first.

## Semigroup modules in PureScript

I don't know about you, but I would be terribly disappointed if PureScript didn't have some of the more useful Semigroups already sitting in a module, locked and loaded with all the class instances and type constraints ready to go.  Well, look no further than [Data.Monoid.Additive](https://pursuit.purescript.org/packages/purescript-monoid/3.0.0/docs/Data.Monoid.Additive#t:Additive) for `Additive x <> Additive y == Additive (x + y)`.  And what about [Data.Monoid.Conj](https://pursuit.purescript.org/packages/purescript-monoid/3.0.0/docs/Data.Monoid.Conj#t:Conj) for `Conj x <> Conj y == Conj (x && y)`?  Look familiar?  They're just `Sum` and `All` in disguise.  But if you're looking for `First` then you'll have to make that one up on your own.

You may be asking why Data.Monoid.XX instead of Data.Semigroup.XX?  Well, we'll have to save the full answer for another tutorial.  But here's a hint - it's all about the laws again, namely the identity law.

## Summary remarks

Some of you may think that, compared to JavaScript or other untyped languages, PureScript's type declarations are all too terribly verbose.  Yes, it does take more lines in PureScript to express a Semigroup type.  But again, the goal is to have future maintainers of your code be able to reason easily about your program, preferably within the time it takes to drink a cup of coffee (two cups max). Moreover, before you waste one precious clock cycle of CPU on execution, I think it is better to use the types to their fullest to prove the correctness of your solution.  So if you will take the time to understand Semigroups, Semirings, and BooleanAlgebra, along with their laws, then these type declarations take you well on your way to achieving this goal.

In the next Tutorial, we'll go through a few examples of Semigroup definitions, similar to the Either examples in [Tutorial 5](https://github.com/adkelley/javascript-to-purescript/tree/master/tut05).  If you are enjoying this series, then please help me to tell others by recommending this article and favoring it on social media.  Thank you and till next time!

## Navigation
[< Tutorial 5](https://github.com/adkelley/javascript-to-purescript/tree/master/tut05) Tutorials [Tutorial 7 >](https://github.com/adkelley/javascript-to-purescript/tree/master/tut07)

You may find that the README for the next tutorial is under construction. But if you're an eager beaver and would like to look ahead, then all the of code samples from Brian's [videos](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) have been ported to PureScript already. But I may amend them as I write the accompanying tutorial markdown.  
