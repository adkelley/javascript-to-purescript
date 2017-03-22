"use strict";

exports.intDegree = function (x) {
  return Math.min(Math.abs(x), 2147483647);
};

exports.intDiv = function (x) {
  return function (y) {
    /* jshint bitwise: false */
    return x / y | 0;
  };
};

exports.intMod = function (x) {
  return function (y) {
    return x % y;
  };
};

exports.numDiv = function (n1) {
  return function (n2) {
    return n1 / n2;
  };
};
