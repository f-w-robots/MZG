import Ember from 'ember';

export default Ember.Route.extend({
  controllerName: 'devices',

  model() {
    return this.store.createRecord('device',{hwid: '', manual: false});
  }
});
