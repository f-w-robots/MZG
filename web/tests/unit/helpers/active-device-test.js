import { activeDevice } from 'web/helpers/active-device';
import { module, test } from 'qunit';

module('Unit | Helper | active device');

test('eq', function(assert) {
  let result = activeDevice(["1", "1"]);
  assert.ok(result === 'active');
});

test('not eq', function(assert) {
  let result = activeDevice(["2", "1"]);
  assert.ok(result === '');
});
