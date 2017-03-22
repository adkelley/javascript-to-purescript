# purescript-psci-support

[![Latest release](http://img.shields.io/bower/v/purescript-psci-support.svg)](https://github.com/purescript/purescript-psci-support/releases)
[![Build Status](https://travis-ci.org/purescript/purescript-psci-support.svg?branch=master)](https://travis-ci.org/purescript/purescript-psci-support)
[![Dependency Status](https://www.versioneye.com/user/projects/578506a076ef4000486f92bc/badge.svg?style=flat)](https://www.versioneye.com/user/projects/578506a076ef4000486f92bc)

Support module for the PSCI interactive mode. This package is required for correct operation of PSCI as of version 0.9.0.

## Installation

```
bower install purescript-psci-support
```

## Documentation

Module documentation is [published on Pursuit](http://pursuit.purescript.org/packages/purescript-psci-support).

## Notes for Library Implementors

If you are implementing an alternative to the Prelude, you may wish to implement the `Eval` class for any types which should support evaluation in the REPL.
