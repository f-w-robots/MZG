import Ember from 'ember';

export default Ember.Route.extend({
  controllerName: 'devices',

  setupController: function(controller, model) {
    this._super(controller, model);
    controller.setModels();
  },

  model(params) {
    return this.store.findRecord('device', params.device_id);
  },
});
