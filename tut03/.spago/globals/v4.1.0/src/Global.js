/* globals exports */
"use strict";

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

var formatNumber = function (format) {
  return function (fail, succ, digits, n) {
    try {
      return succ(n[format](digits));
    }
    catch (e) {
      return fail(e.message);
    }
  };
};

exports._toFixed = formatNumber("toFixed");
exports._toExponential = formatNumber("toExponential");
exports._toPrecision = formatNumber("toPrecision");

var encdecURI = function (encdec) {
  return function (fail, succ, s) {
    try {
      return succ(encdec(s));
    }
    catch (e) {
      return fail(e.message);
    }
  };
};

exports._decodeURI = encdecURI(decodeURI);
exports._encodeURI = encdecURI(encodeURI);
exports._decodeURIComponent = encdecURI(decodeURIComponent);
exports._encodeURIComponent = encdecURI(encodeURIComponent);
