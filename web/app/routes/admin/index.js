import Ember from 'ember';

export default Ember.Route.extend({
  controllerName: 'admin',

  model() {
    return this.store.findAll('group');
  },
});
