"use strict";

/* exports.handleCallbackImpl = function(onFailure, onSuccess, f) {
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


exports.getImpl = function(uri, fail, done) {
    return function() {
        require('request')(uri, function(err, _, body) {
            if (err) {
                fail(err)();
            } else {
                done(body)();
            }
        });
    };
};
