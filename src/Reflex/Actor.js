'use strict';

var Control_Monad_Aff = require('../Control.Monad.Aff');

exports.startActor = function(config) {
  return function(onSuccess, onError) {
    try {
      var fullPath = config.path[0] === '/'
        ? config.path
        : process.cwd() + '/' + config.path;
      var $module = require(fullPath);
      return $module.start(function(state) {
        onSuccess($module.invoke(state));
      }, onError);
    } catch (e) {
      onError(e);
      return Control_Monad_Aff.nonCanceler;
    }
  };
};
