"use strict";

exports.currentExample = { previewPath: "./resources/example.json" };

exports.previewPath = function(example) {
  return example.previewPath;
};

exports.defaultPreview = { a: 1, b: 2};

exports.dbUrl = function(config) {
  return config.url;
};
