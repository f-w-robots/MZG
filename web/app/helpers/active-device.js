import Ember from 'ember';

export function activeDevice(params/*, hash*/) {
  if(params[0] === params[1]) {
    return 'active';
  }
}

export default Ember.Helper.helper(activeDevice);
