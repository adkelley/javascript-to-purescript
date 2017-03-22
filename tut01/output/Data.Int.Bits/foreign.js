"use strict";

// module Data.Int.Bits

exports.and = function (n1) {
  return function (n2) {
    /* jshint bitwise: false */
    return n1 & n2;
  };
};

exports.or = function (n1) {
  return function (n2) {
    /* jshint bitwise: false */
    return n1 | n2;
  };
};

exports.xor = function (n1) {
  return function (n2) {
    /* jshint bitwise: false */
    return n1 ^ n2;
  };
};

exports.shl = function (n1) {
  return function (n2) {
    /* jshint bitwise: false */
    return n1 << n2;
  };
};

exports.shr = function (n1) {
  return function (n2) {
    /* jshint bitwise: false */
    return n1 >> n2;
  };
};

exports.zshr = function (n1) {
  return function (n2) {
    /* jshint bitwise: false */
    return n1 >>> n2;
  };
};

exports.complement = function (n) {
  /* jshint bitwise: false */
  return ~n;
};
