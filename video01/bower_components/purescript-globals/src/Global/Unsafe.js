/* globals exports, JSON */
"use strict";

// module Global.Unsafe

exports.unsafeStringify = function (x) {
  return JSON.stringify(x);
};

exports.unsafeToFixed = function (digits) {
  return function (n) {
    return n.toFixed(digits);
  };
};

exports.unsafeToExponential = function (digits) {
  return function (n) {
    return n.toExponential(digits);
  };
};

exports.unsafeToPrecision  = function (digits) {
  return function (n) {
    return n.toPrecision(digits);
  };
};

