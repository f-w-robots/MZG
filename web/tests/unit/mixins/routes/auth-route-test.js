import Ember from 'ember';
import RoutesAuthRouteMixin from 'web/mixins/routes/auth-route';
import { module, test } from 'qunit';

module('Unit | Mixin | routes/auth route');

// Replace this with your real tests.
test('it works', function(assert) {
  let RoutesAuthRouteObject = Ember.Object.extend(RoutesAuthRouteMixin);
  let subject = RoutesAuthRouteObject.create();
  assert.ok(subject);
});
