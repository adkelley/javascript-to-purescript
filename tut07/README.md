# Semigroup Examples (DRAFT)

![series banner](../resources/glitched-abstract.jpg)

> *Note: This is* **Tutorial 7** *in the series* **Make the leap from JavaScript to PureScript** *. Be sure*
> *to read the series introduction where I cover the goals & outline, and the installation,*
> *compilation, & running of PureScript. I will be publishing a new tutorial approximately*
> *once-per-week. So come back often, there is a lot more to come!*

> [<< Introduction](https://github.com/adkelley/javascript-to-purescript) [< Tutorial 6](https://github.com/adkelley/javascript-to-purescript/tree/master/tut06)

Welcome to Tutorial 7 in the series **Make the leap from Javascript to PureScript**.  I hope you've enjoyed the learnings thus far.  Be sure to read the series [Introduction](https://github.com/adkelley/javascript-to-purescript) to learn how to install and run PureScript. I borrowed (with permission) this series outline and javascript code samples from the egghead.io course [Professor Frisby Introduces Composable Functional JavaScript](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) by
[Brian Lonsdorf](https://github.com/DrBoolean) - thank you, Brian! A fundamental assumption is that you have watched his [video](https://egghead.io/lessons/javascript-semigroup-examples) before tackling the equivalent PureScript abstraction featured in this tutorial.  Brian covers the featured concepts extremely well, and it's better that you understand its implementation in the comfort of JavaScript.

If you read something that you feel could be explained better, or a code example that needs refactoring, then please let me know via a comment or send me a pull request on [Github](https://github.com/adkelley/javascript-to-purescript/tree/master/tut07).  Finally, If you are enjoying this series then please help me to tell others by recommending this article and/or favoring it on social media

## Robot Voice: SHALL WE PLAY A GAME?
Imagine we've developed an online game and one of our players,  Nico has made three accounts accidentally; issuing a ticket to merge them into one.  Well, my first reaction is to ban Nico permanently. Regrettably, even in my own imaginary games company, that decision is well above my pay grade. So we'll just have to figure out how to accommodate Nico's request.

Anytime you see the words merge, combine, consolidate, etc. in a user story; you should be thinking Semigroups immediately.  So, let's help poor Nico out by combining her credentials with the aid of our Semigroup types from [Tutorial 6](https://github.com/adkelley/javascript-to-purescript/tree/master/tut06).  But instead of merely presenting the code and calling it a day, I'll make this tutorial a little more interesting by introducing a few new constructs in PureScript; starting with Records.

## Record quick start
If you're a JavaScript developer, then you're probably using Objects on a daily basis.  You know, those name:value pairs we call properties; enclosed in braces. I'm sure you've seen them, but just in case:

```javascript
var immy = { firstName: "Imogen", lastName: "Heap", age: 39 };
```

And by migrating to PureScript, perhaps you've already shed a tear or two; contemplating that sad and tearful goodbye to your dear old friend. Well, dry those tears and put your big boy (or girl) pants back on, because PureScript just waved hello with its `Record` type constructor.  Porting this code snippet we get:

```haskell
type Person =
  { firstName :: String
  , lastName  :: String
  , age       :: Int
  }

immy :: Person
immy =
  { firstName: "Imogen"
  , lastName: "Heap"
  , age: 39
  }
```

Now that wasn't so bad. In fact, the syntax for JavaScript objects and PureScript records are spitting images of one another.  Note that `{ ... }` is syntactic sugar for the `Record` type constructor. Thus,  `{ firstName :: String }` is the same as `Record ( firstName :: String )`.  Also, records have a few magical powers worth mentioning.  For one, just like JavaScript objects, we have the ability to add extra `name:value` properties to records:

```haskell
type Person r =
  { firstName :: String
  , lastName  :: String
  , age       :: Int
  | r
  }

type Musician = Person ( genre :: String )
```
Shazam!  But let's go over a couple of 'minor' changes from the first example.  By declaring `Person r`, I am *instantiating* that `Person` may contain extra record fields `r`.  Thus `Person` has become a *row-polymorphic* record (or extensible record type).  And we do that by creating the type `Musician` as an extension of  `Person r`, with the additional field `genre`.  Be careful to use parenthesis when creating a record extension, since `r` has to be a row kind, not a record type.  Now that we have defined an extension `Musician`, let's create one of my favorites:

```haskell
immy :: Musician
immy =
  { firstName: "Imogen"
  , lastName: "Heap"
  , age: 39
  , genre: "Electronic"
  }
```  

What does this all mean?  Well, if this looks unfamiliar to you then recall that we covered the similar concept of extensible effects when we discussed native side-effects in [Tutorial 4](https://github.com/adkelley/javascript-to-purescript/tree/master/tut04P1).  To review:

```haskell
main :: forall e. Eff (console :: CONSOLE | e) Unit
```

We are parameterizing the `Eff` type constructor with a row of effects and its return type.  More specifically, we declare that `main` produces a row that consists of the `CONSOLE` effect, and perhaps additional effects `e`, returning `Unit` (values with no computational content).

Another magic power and a real keystroke saver is assignment using wild cards:


```haskell
makeMusician :: String -> String -> Int -> String -> Musician
makeMusician = { firstName: _, lastName: _, age: _ , genre: _ }
```

And for one last magic power, Record updates are available just like in Haskell:

```haskell
setGenre :: String -> Musician -> Musician
setGenre g m = m { genre = g }
```

```haskell
main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  let ih = makeMusician "Imogen" "Heap" 39 "Electronic"
  logShow $ _.genre ih
  logShow $ _.genre $ setGenre "Alternative" ih
```

I have included these examples in my [github repository](https://github.com/adkelley/javascript-to-purescript/tree/master/tut07), so feel free to try them yourself.

Wow!  We covered a lot of ground here, but there's lots more to learn.  I encourage you to have a look at the [documentation](https://github.com/purescript/documentation/blob/master/language/Records.md) and also [Chapter 8.14]https://leanpub.com/purescript/read#leanpub-auto-objects-and-rows in PureScript by Example.

## Say hello to Additive, Conj, and First

As mentioned in [Tutorial 6](https://github.com/adkelley/javascript-to-purescript/tree/master/tut06), PureScript already has Semigroup constructors that copy the functionality of `Sum` & `All`. They're named `Additive` and `Conj` from the modules [Data.Monoid.Additive](https://pursuit.purescript.org/packages/purescript-monoid/3.0.0/docs/Data.Monoid.Additive#t:Additive) and [Data.Monoid.Conj](https://pursuit.purescript.org/packages/purescript-monoid/3.0.0/docs/Data.Monoid.Conj#t:Conj), respectively.  So I'm going to retire `Sum` & `All` in favor of the `Additive` and `Conj` from here on.

I am also retiring the Semigroup `First` in favor of [Data.Maybe.First](https://pursuit.purescript.org/packages/purescript-maybe/3.0.0/docs/Data.Maybe.First). But this type signature is a little different from the `First` we saw in Tutorial 6.  Fortunately, it's relatively easy to modify our original implementation.  Plus, it allows me to introduce a major type constructor `Maybe` (sometimes called `Option` in other FP languages), which is the subject of our next in-depth look.

## Maybe I will, and Maybe I won't

Imagine we decide to augment our `Person` record from above by giving the user the option to withhold their age.  After all, my mother taught me that it is impolite to ask someone their age - right?  Well, the `Maybe` type constructor is an excellent way to make optional cases like this one explicit.  Now we could just assign a 0 to `age` or leave it blank, but that's not how we roll in PureScript.  So, instead of confusing readers of our program, let make this change explicit in our code.  As we can see below, the Maybe constructor has two potential values, `Nothing` or `Just a`.

```haskell
data Maybe a = Nothing | Just a
```
You can think of this as something like a type-safe `null`, where `Nothing` is `null` and `Just a`
is the non-null value `a`.  So, augmenting the `age` type in our `Person` record, we get:

```haskell
type Person =
  { firstName :: String
  , lastName  :: String
  , age       :: Maybe Int
  }
```

And, we follow this with an update to our `makePerson` function:

```haskell
makePerson :: String -> String -> Maybe Int -> Person
makePerson = { firstName: _, lastName: _, age: _ }
```

Finally, here's our function assignment:

```haskell
makePerson "Imogen" "Heap" (Just 39)
makePerson "Imogen" "Heap" Nothing
```

Note that `Maybe` is also a functor,  so `map` (covered in Tutorial TK link) works like a charm:

```haskell
isOverForty :: Maybe Int -> Maybe Boolean
isOverForty = map (\x -> testForty x) where
  testForty age = if age > 40 then true else false
```

If the argument to `overForty` is `Nothing` then `map` will skip the `testForty` and return `Nothing`; otherwise, run `testForty` and return `Just true` or `Just false`.

Now that we've introduced records, the `Maybe` type constructor, and retired `Sum`, `All` and `First`, we're ready to solve the problem of merging Nico's multiple game accounts using Semigroups.

## Merging multiple records using Semigroups

To repeat what we want to accomplish in the main topic of this tutorial: we have a user, Nico, who has accidentally created three separate accounts on our site, and has subsequently issued a ticket to merge them together.  How do we go about closing this ticket?

One nice trick with semigroups is that if you have a data structure that is entirely made up of semigroups, then that data structure is also a semigroup.  Thus, to append two or more of these data structures together, we append each of the objects that make up these semigroups.  

Now, after covering records in detail, I hope it is no surprise that I'm using this construct to represent a user account:

```haskell
type Account = Record
  ( name    :: First String
  , isPaid  :: Conj Boolean
  , points  :: Additive Int
  , friends :: Array String
  )
```

We also want a function to log the contents of an `Account` to the console.  As shown below, I'm using a couple of new tricks, namely pattern matching and folds to 'pretty print' the record to the console.

```haskell
showAccount :: Account -> String
showAccount { name, isPaid, points, friends } =
  foldr (<>) ""
    [ "{ name: ", show name, ",\n  "
    , "isPaid: ", show isPaid, ",\n  "
    , "points: ", show points, ",\n  "
    , "friends: ", show friends, "  }"
    ]
```    

### Pattern Matching

In many FP languages, pattern matching is an integral part of development.  In `showAccount`, we used it to match values against the field names of `Account`.   But there are other variations on pattern matching that you should be made aware.  For example, say we want to write a recursive function to find the sum of integers in a list.

```haskell
sum :: List Int -> Int
sum Nil = 0
sum (x : xs) = x + sum xs
```

We define `sum` as a function that pattern matches on two data constructors `Nil` and `(x : xs)`.  The behavior of `sum` will be different based on the pattern match.  If it is `Nil` then were at the end of the list, so add `0` to the value computed from the last recursive call to `sum` and terminate; otherwise, continue to pattern match by deconstructing the head and tail of the list, (`x : xs`).  At each step, we add `x` (the head of the list) and recursively call `sum` with `xs` (the tail of the list) until reaching the end of the list.

### Folds

In `showAccount`, I used the function fold right (`foldr`) to concatenate my labels and contents of `Account` into one big string.  Otherwise, my function would have looked like this:

```haskell
showAccount :: Account -> String
showAccount { name, isPaid, points, friends } =
  "{ name: "  <> show name    <> ",\n  " <>
  "isPaid: "  <> show isPaid  <> ",\n  " <>
  "points: "  <> show points  <> ",\n  " <>
  "friends: " <> show friends <> "  }"
```

Like pattern matching, folds are ubiquitous in FP and will become an integral part of your development in PureScript. We use them to reduce any structure that is foldable, e.g., lists and arrays, into a single object.  Let's look at the type signature for `foldr`.  The type signature is saying that we have a foldable structure `f`, an initial value `b`, and a function that takes `a` and `b` and returns `b`.

```haskell
foldr :: forall a b f. Foldable f => (a -> b -> b) -> b -> f a -> b
```

Take a look our recursive `sum` function from before, because you may see some similarities.  Is it possible to turn this recursive function into a fold?  Absolutely!

```haskell
sum' :: List Int -> Int
sum' xs = foldr (\z x -> z + x) 0 xs
```

Typically, we refactor `sum` to be *point-free* by removing `xs`, but I've left it in for demonstration purposes.  So how does `foldr` evaluate?  Well, let's look underneath the hood, and then it will be clear:

```haskell
foldr :: forall a b. (a -> b -> b) -> b -> List a -> b
foldr f z xs =
  case xs of
    Nil -> z
    (x : xs) -> f x foldr f z xs
```    

You should see that `foldr` is right-associative, which means how the associativity of an operator is grouped in the absence of parenthesis.  Putting the parenthesis back in, we get: `(x : xs) -> f x (foldr f z xs)`.  Another thing to pay attention is the real potential of blowing your stack.  For a very large list, before ever making its first evaluation, the number of recursive calls that are pushed onto the stack will be great.  So if there is that potential, then you may want to switch to `foldl`.

```haskell
foldl f z []     = z
foldl f z (x:xs) = let z' = z `f` x
                   in foldl f z' xs
```                   
PureScript's expression evaluation is strict, not lazy.  So, with `foldl`, you don't have to worry about lazy evaluation allocating a large number `z` variables (i.e., z1, z2, z3, . . ., zn) onto the heap.  Instead, the evaluation of `z` will be performed at each step of the fold.



## Navigation
[< Tutorial 6](https://github.com/adkelley/javascript-to-purescript/tree/master/tut06) Tutorials [Tutorial 8 >](https://github.com/adkelley/javascript-to-purescript/tree/master/tut08)

You may find that the README for the next tutorial is under construction. But if you're an eager beaver and would like to look ahead, then all the of code samples from Brian's [videos](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) have been ported to PureScript already. But I may amend them as I write the accompanying tutorial markdown.  
