"use strict";

exports.setTimeout = function(ms) {
  return function(fn) {
    return function() {
      return setTimeout(fn, ms);
    }
  }
}
