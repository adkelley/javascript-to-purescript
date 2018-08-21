"use strict";

exports.myAdd = function(x) {
  return function(y) {
    return x + y;
  };
};
