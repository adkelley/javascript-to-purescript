"use strict";

exports.unsafePerformEffect = function (f) {
  return f();
};
