"use strict";

var refEq = function (r1) {
  return function (r2) {
    return r1 === r2;
  };
};

exports.eqBooleanImpl = refEq;
exports.eqIntImpl = refEq;
exports.eqNumberImpl = refEq;
exports.eqCharImpl = refEq;
exports.eqStringImpl = refEq;

exports.eqArrayImpl = function (f) {
  return function (xs) {
    return function (ys) {
      if (xs === ys) return true;
      if (xs.length !== ys.length) return false;
      for (var i = 0; i < xs.length; i++) {
        if (!f(xs[i])(ys[i])) return false;
      }
      return true;
    };
  };
};
