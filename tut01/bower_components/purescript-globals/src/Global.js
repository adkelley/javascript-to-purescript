/* globals exports */
"use strict";

// module Global

exports.nan = NaN;

exports.isNaN = isNaN;

exports.infinity = Infinity;

exports.isFinite = isFinite;

exports.readInt = function (radix) {
  return function (n) {
    return parseInt(n, radix);
  };
};

exports.readFloat = parseFloat;

exports.decodeURI = decodeURI;
exports.encodeURI = encodeURI;
exports.decodeURIComponent = decodeURIComponent;
exports.encodeURIComponent = encodeURIComponent;
