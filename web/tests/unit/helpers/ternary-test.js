import { ternary } from 'web/helpers/ternary';
import { module, test } from 'qunit';

module('Unit | Helper | ternary');

test('true', function(assert) {
  let result = ternary([true, 1, 2]);
  assert.ok(result === 1);
});

test('false', function(assert) {
  let result = ternary([false, 1, 2]);
  assert.ok(result === 2);
});
