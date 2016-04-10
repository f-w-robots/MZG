import Ember from 'ember';

export default Ember.Route.extend({
  controllerName: 'devices',

  setupController: function(controller, model) {
    this._super(controller, model);
    controller.setup();
  },

  model(params) {
    return this.store.findRecord('algorithm', params.algorithm_id);
  },
});
