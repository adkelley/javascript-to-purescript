"use strict";

exports.getImpl = function(uri, fail, success) {
    return function() {
        require('request')(uri, function(err, _, body) {
            if (err) {
                fail(err)();
            } else {
                success(body)();
            }
        });
    };
};


/* Alternative approach see https://github.com/purescript-node/purescript-node-fs/blob/master/src/Node/FS/Async.js
 *
 * exports.handleCallbackImpl = function(onFailure, onSuccess, f) {
 *     return function (error, request, body) {
 *         if (error) {
 *             f(onFailure(error))();
 *         } else {
 *             f(onSuccess(body))();
 *         }
 *     };
 * };
 *
 *
 * exports.getImpl = function(uri, handleCallback) {
 *     return function() {
 *         require('request')(uri, handleCallback);
 *     }
 * }; */
