import Ember from 'ember';

export default Ember.Route.extend({
  setupController: function(controller, model) {
   this._super(controller, model);
   controller.set('store', this.store);
 },

  model() {
    return this.store.findRecord('user', 'current').then(function(user) {
      return Ember.RSVP.hash({
        devices: this.store.findAll('device'),
        algorithms: this.store.findAll('algorithm'),
        user: this.store.findRecord('user', 'current'),
      });
    }.bind(this), function() {
      return Ember.RSVP.hash({fail: true});
    })

  },

  actions: {
    // error(error, transition) {
    //   if (error) {
    //     // return this.render('error-page');
    //     // return this.transitionTo('error-page');
    //   }
    // }
  }
});
