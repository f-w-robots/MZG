import Ember from 'ember';

export function activeDevice(params) {
  return params[0] === params[1] ? 'active' : '';
}

export default Ember.Helper.helper(activeDevice);
