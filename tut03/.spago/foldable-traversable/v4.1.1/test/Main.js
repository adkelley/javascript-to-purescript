"use strict";

exports.arrayFrom1UpTo = function (n) {
  var result = [];
  for (var i = 1; i <= n; i++) {
    result.push(i);
  }
  return result;
};

exports.arrayReplicate = function (n) {
  return function (x) {
    var result = [];
    for (var i = 1; i <= n; i++) {
      result.push(x);
    }
    return result;
  };
};
