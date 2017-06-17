"use strict";

const street1 = { name: "easy street" }
const address1 = { street: street1 }
const currentUser =
  { name: "ethel", premium: true, preferences: "ethel's prefs", address: address1 };

exports["null"] = null;

exports.address = function(user) {
  return user.address;
};

exports.preferences = function(user) {
  return user.preferences;
};

exports.premium = function(user) {
  return user.premium;
};

exports.name = function(user) {
  return user.name;
};

exports.street = function (address) {
  return address.street;
};

exports.streetName = function (street) {
  return street.name;
};

exports["currentUser"] = currentUser;
