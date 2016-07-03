import Ember from 'ember';

export default Ember.Mixin.create({
  beforeModel: function(transition) {
    this.store.findRecord('user', 'current').then(function(user) {
      if(!user.get('authorized')) {
        this.transitionTo('index');
      }
    }.bind(this), function() {
      this.transitionTo('index');
    }.bind(this));
  },
});
