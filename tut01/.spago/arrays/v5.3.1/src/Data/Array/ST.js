"use strict";

exports.empty = function () {
  return [];
};

exports.peekImpl = function (just) {
  return function (nothing) {
    return function (i) {
      return function (xs) {
        return function () {
          return i >= 0 && i < xs.length ? just(xs[i]) : nothing;
        };
      };
    };
  };
};

exports.poke = function (i) {
  return function (a) {
    return function (xs) {
      return function () {
        var ret = i >= 0 && i < xs.length;
        if (ret) xs[i] = a;
        return ret;
      };
    };
  };
};

exports.popImpl = function (just) {
  return function (nothing) {
    return function (xs) {
      return function () {
        return xs.length > 0 ? just(xs.pop()) : nothing;
      };
    };
  };
};

exports.pushAll = function (as) {
  return function (xs) {
    return function () {
      return xs.push.apply(xs, as);
    };
  };
};

exports.shiftImpl = function (just) {
  return function (nothing) {
    return function (xs) {
      return function () {
        return xs.length > 0 ? just(xs.shift()) : nothing;
      };
    };
  };
};

exports.unshiftAll = function (as) {
  return function (xs) {
    return function () {
      return xs.unshift.apply(xs, as);
    };
  };
};

exports.splice = function (i) {
  return function (howMany) {
    return function (bs) {
      return function (xs) {
        return function () {
          return xs.splice.apply(xs, [i, howMany].concat(bs));
        };
      };
    };
  };
};

exports.unsafeFreeze = function (xs) {
  return function () {
    return xs;
  };
};

exports.unsafeThaw = function (xs) {
  return function () {
    return xs;
  };
};

function copyImpl(xs) {
  return function () {
    return xs.slice();
  };
}

exports.freeze = copyImpl;

exports.thaw = copyImpl;

exports.sortByImpl = function (comp) {
  return function (xs) {
    return function () {
      return xs.sort(function (x, y) {
        return comp(x)(y);
      });
    };
  };
};

exports.toAssocArray = function (xs) {
  return function () {
    var n = xs.length;
    var as = new Array(n);
    for (var i = 0; i < n; i++) as[i] = { value: xs[i], index: i };
    return as;
  };
};
