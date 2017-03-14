"use strict";

exports.parseFloatImpl = function(just, nothing, x) {
  if (parseFloat(x)) {
    return just(x);
  } else {
    return nothing;
  }
};
