import Ember from 'ember';

export default Ember.Route.extend({
  setupController: function(controller, model) {
   this._super(controller, model);
   controller.set('store', this.store);
 },

 beforeModel: function(transition) {
   this.store.findRecord('user', 'current').then(function(user) {
     if(!user.get('authorized')) {
       this.transitionTo('index');
     }
   }.bind(this), function() {
     this.transitionTo('index');
   }.bind(this));
 },

  model() {
    return this.store.findRecord('user', 'current').then(function(user) {
      return this.store.findRecord('user', 'current').then(function(user) {
        if(user.get('authorized')) {
          this.transitionTo('/devices');
        }
      }.bind(this));
    }.bind(this), function() {
      return Ember.RSVP.hash({fail: true});
    });

  },
});
