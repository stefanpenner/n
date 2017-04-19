'use strict';
const Nomdown = require('broccoli-nomdown');

module.exports = function() {
  return new Nomdown(__dirname + '/n')
};
