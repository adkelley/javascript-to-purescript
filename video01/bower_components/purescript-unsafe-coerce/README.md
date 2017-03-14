# purescript-unsafe-coerce

[![Latest release](http://img.shields.io/bower/v/purescript-unsafe-coerce.svg)](https://github.com/purescript/purescript-unsafe-coerce/releases)
[![Build Status](https://travis-ci.org/purescript/purescript-unsafe-coerce.svg?branch=master)](https://travis-ci.org/purescript/purescript-unsafe-coerce)
[![Dependency Status](https://www.versioneye.com/user/projects/56ae47da7e03c7003ba4166b/badge.svg?style=flat)](https://www.versioneye.com/user/projects/56ae47da7e03c7003ba4166b)

A _highly unsafe_ function, which can be used to persuade the type system that any type is the same as any other type. When using this function, it is your (that is, the caller's) responsibility to ensure that the underlying representation for both types is the same.

There are few situations where it is acceptable to use this function, it should only ever appear as an internal implementation detail of a library, never as a function used in a "normal" codebase.

## Installation

```
bower install purescript-unsafe-coerce
```

## Documentation

Module documentation is [published on Pursuit](http://pursuit.purescript.org/packages/purescript-unsafe-coerce).
