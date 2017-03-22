"use strict";

// module Partial

exports.crashWith = function () {
  return function (msg) {
    throw new Error(msg);
  };
};
