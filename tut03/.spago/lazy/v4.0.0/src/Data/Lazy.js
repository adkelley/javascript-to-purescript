"use strict";

exports.defer = function (thunk) {
  var v = null;
  return function() {
    if (thunk === undefined) return v;

    v = thunk();
    thunk = undefined; // eslint-disable-line no-param-reassign
    return v;
  };
};

exports.force = function (l) {
  return l();
};
