import Ember from 'ember';

export default Ember.Route.extend({
  controllerName: 'devices',

  setupController: function(controller, model) {
    controller.set('algorithms', this.store.findAll('algorithm'));
    controller.set('interfaces', this.store.findAll('interface'));
    controller.set('model', model);
  },

  model(params) {
    return this.store.findRecord('device', params.device_id);
  },
});
