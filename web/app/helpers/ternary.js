import Ember from 'ember';

export function ternary(params) {
  return params[0] ? params[1] : params[2];
}

export default Ember.Helper.helper(ternary);
