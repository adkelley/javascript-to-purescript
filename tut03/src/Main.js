"use strict";

// Manually currying the arguments is quite
// tedious and error prone
// exports.sliceImpl = function(beginIndex) {
//   return function(endIndex) {
//     return function(string) {
//       if (endIndex === 0) {
//         return string.slice(beginIndex);
//       } else {
//         return string.slice(beginIndex, endIndex);
//       }
//     }
//   }
// };

// Now this is more like it, thanks to Fn0 - Fn10 
exports.sliceImpl = function(beginIndex, endIndex, string) {
  if (endIndex === 0) {
    return string.slice(beginIndex);
  } else {
    return string.slice(beginIndex, endIndex);
  }
};
