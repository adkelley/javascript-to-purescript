"use strict";

exports.toUpperCase = function (str) {
  return str.toUpperCase();
};

exports.substrImpl = function (start) {
  return function (str) {
    return str.substr(start);
  };
};
