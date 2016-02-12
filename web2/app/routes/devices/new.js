import Ember from 'ember';

export default Ember.Route.extend({
  setupController: function(controller, song) {
    controller.set('model', song);
  },

  model() {
    return this.store.createRecord('device',{hwid: 'neeeww', manual: false});
  }
});
