import Ember from 'ember';

export default Ember.Route.extend({
  controllerName: 'profile',

  model() {
    return this.store.findRecord('user', 'current');
  }
});
