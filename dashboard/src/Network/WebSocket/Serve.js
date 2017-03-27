'use strict';

var ws = require('ws');

exports.newServer = function(config) {
  return function() {
    return new ws.Server({
      host: config.host,
      port: config.port,
    });
  };
};

exports.clients = function(server) {
  return function() {
    return Array.from(server.clients);
  };
};

exports.sendString = function(client) {
  return function(message) {
    return function() {
      client.send(message);
    };
  };
};
