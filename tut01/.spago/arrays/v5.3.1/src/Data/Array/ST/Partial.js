"use strict";

exports.peekImpl = function (i) {
  return function (xs) {
    return function () {
      return xs[i];
    };
  };
};

exports.pokeImpl = function (i) {
  return function (a) {
    return function (xs) {
      return function () {
        xs[i] = a;
        return {};
      };
    };
  };
};
