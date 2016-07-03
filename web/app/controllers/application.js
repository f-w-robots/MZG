import Ember from 'ember';

export default Ember.Controller.extend({
  store: Ember.inject.service('store'),

  setup: function() {
    this.set('currentUser', this.store.findRecord('user', 'current'));
  }.on('init'),
});
