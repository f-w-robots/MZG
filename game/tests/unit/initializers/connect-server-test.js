import Ember from 'ember';
import ConnectServerInitializer from 'game/initializers/connect-server';
import { module, test } from 'qunit';

let application;

module('Unit | Initializer | connect server', {
  beforeEach() {
    Ember.run(function() {
      application = Ember.Application.create();
      application.deferReadiness();
    });
  }
});

// Replace this with your real tests.
test('it works', function(assert) {
  ConnectServerInitializer.initialize(application);

  // you would normally confirm the results of the initializer here
  assert.ok(true);
});
