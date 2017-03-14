"use strict";
var Prelude = require("../Prelude");
var Control_Monad_Eff = require("../Control.Monad.Eff");
var Control_Monad_Eff_Console = require("../Control.Monad.Eff.Console");
var Data_Char = require("../Data.Char");
var Data_Foldable = require("../Data.Foldable");
var Data_Int = require("../Data.Int");
var Data_Maybe = require("../Data.Maybe");
var Data_String = require("../Data.String");
var Unsafe_Coerce = require("../Unsafe.Coerce");
var Data_Functor = require("../Data.Functor");
var Data_Show = require("../Data.Show");
var Data_Semigroup = require("../Data.Semigroup");
var Data_Function = require("../Data.Function");
var Data_Semiring = require("../Data.Semiring");
var Data_Monoid = require("../Data.Monoid");
var Control_Bind = require("../Control.Bind");

/**
 *  const Box = x =>
 */
var Box = function (x) {
    return x;
};

/**
 *  inspect: () => 'Box($(x))'
 */
var showBox = function (dictShow) {
    return new Data_Show.Show(function (v) {
        return "Box(" + (Data_Show.show(dictShow)(v) + ")");
    });
};

/**
 *  map: f => (f(x))
 */
var functorBox = new Data_Functor.Functor(function (f) {
    return function (v) {
        return f(v);
    };
});

/**
 *  fold: f => f(x)
 */
var foldableBox = new Data_Foldable.Foldable(function (dictMonoid) {
    return function (f) {
        return function (v) {
            return f(v);
        };
    };
}, function (f) {
    return function (z) {
        return function (v) {
            return f(z)(v);
        };
    };
}, function (f) {
    return function (z) {
        return function (v) {
            return f(v)(z);
        };
    };
});
var nextCharForNumberString = function (str) {
    return Data_Foldable.foldMap(foldableBox)(Data_Monoid.monoidString)(function (c) {
        return Data_String.toLower(Unsafe_Coerce.unsafeCoerce(c));
    })(Data_Functor.map(functorBox)(function (i) {
        return Data_Char.fromCharCode(i);
    })(Data_Functor.map(functorBox)(function (i) {
        return i + 1 | 0;
    })(Data_Functor.map(functorBox)(function (s) {
        return Data_Maybe.fromMaybe(0)(Data_Int.fromString(s));
    })(Data_Functor.map(functorBox)(Data_String.trim)(str)))));
};
var main = function __do() {
    Control_Monad_Eff_Console.log("Create Linear Data Flow with Container Style Types (Box)")();
    return Control_Monad_Eff_Console.log(nextCharForNumberString("     64   "))();
};
module.exports = {
    Box: Box, 
    main: main, 
    nextCharForNumberString: nextCharForNumberString, 
    functorBox: functorBox, 
    foldableBox: foldableBox, 
    showBox: showBox
};
