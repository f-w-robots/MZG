import Ember from 'ember';

export default Ember.Route.extend({
  controllerName: 'devices',

  model(params) {
    return this.store.findRecord('device', params.device_id);
  },
});
