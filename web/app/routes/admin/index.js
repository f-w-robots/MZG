import Ember from 'ember';

export default Ember.Route.extend({
  controllerName: 'admin',

  model() {
    console.log('s');
    return this.store.findAll('group');
  },
});
