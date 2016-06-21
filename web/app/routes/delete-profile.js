import Ember from 'ember';

export default Ember.Route.extend({
  controllerName: 'profile',

  beforeModel: function(transition) {
    this.store.findRecord('user', 'current').then(function(user) {
      if(!user.get('authorized')) {
        this.transitionTo('index');
      }
    }.bind(this));
  },

  model() {
    return this.store.findRecord('user', 'current');
  }
});
