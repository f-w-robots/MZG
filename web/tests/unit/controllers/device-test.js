import { moduleFor, test } from 'ember-qunit';

moduleFor('controller:device', 'Unit | Controller | device', {
  needs: ['controller:devices', 'service:devices-manager']
});

// Replace this with your real tests.
test('it exists', function(assert) {
  let controller = this.subject();
  assert.ok(controller);
});
