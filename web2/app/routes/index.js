import Ember from 'ember';

export default Ember.Route.extend({
  model() {
    return this.store.findAll('device');
  },

  // interfaces() {
  //   return this.store.findAll('interfaces');
  // }
});
