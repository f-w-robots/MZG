import Ember from 'ember';

export default Ember.Route.extend({
  setupController: function(controller, model) {
   this._super(controller, model);
   controller.set('store', this.store);
 },

  model() {
    return Ember.RSVP.hash({
      devices: this.store.findAll('device'),
      algorithms: this.store.findAll('algorithm'),
      user: this.store.findRecord('user', 'current'),
    });
  },
});
