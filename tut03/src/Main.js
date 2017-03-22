"use strict";

exports.sliceImpl = function(beginIndex, endIndex, string) {
  if (endIndex === 0) {
    return string.slice(beginIndex);
  } else {
    return string.slice(beginIndex, endIndex);
  }
};
