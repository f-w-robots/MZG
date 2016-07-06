/*jshint node:true*/
/* global require, module */
var EmberApp = require('ember-cli/lib/broccoli/ember-app');
var funnel = require('ember-cli/node_modules/broccoli-funnel');
var mergeTrees = require('broccoli-merge-trees');

module.exports = function(defaults) {
  var app = new EmberApp(defaults, {
    // Add options here
  });

  app.import('/vendor/css/leftMenu.css');

  app.import('bower_components/js-md5/build/md5.min.js');

  app.import(app.bowerDirectory + '/bootstrap/dist/js/bootstrap.js');
  app.import(app.bowerDirectory + '/bootstrap/dist/css/bootstrap.css');
  app.import('bower_components/bootstrap-social/bootstrap-social.css');

  var ace = new funnel('bower_components/ace-builds/src-min-noconflict', {
    srcDir: '/',
    include: ['**/*.js'],
    destDir: '/assets/ace'
  });

  app.import('bower_components/font-awesome/css/font-awesome.css');
  var fontawesome = new funnel('bower_components/font-awesome/fonts', {
    srcDir: '/',
    destDir: 'fonts'
  });

  var bootstrap = new funnel('bower_components/bootstrap/fonts', {
    srcDir: '/',
    destDir: 'fonts'
  });

  var merged = mergeTrees([app.toTree(), ace, fontawesome, bootstrap], {
       overwrite: true
  });

  app.import('/vendor/css/tabs-left.css');
  app.import('/vendor/css/leftMenu.css');
  app.import('/vendor/css/login.css');
  app.import('/vendor/css/homepage.css');

  // Use `app.import` to add additional libraries to the generated
  // output files.
  //
  // If you need to use different assets in different
  // environments, specify an object as the first parameter. That
  // object's keys should be the environment name and the values
  // should be the asset to use in that environment.
  //
  // If the library that you are including contains AMD or ES6
  // modules that you would like to import into your application
  // please specify an object with the list of modules as keys
  // along with the exports of each module as its value.

  return app.toTree(merged);
};
