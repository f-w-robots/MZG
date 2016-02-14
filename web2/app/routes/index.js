import Ember from 'ember';

export default Ember.Route.extend({
  model() {
    return Ember.RSVP.hash({
        devices: this.store.findAll('device'),
        interfaces: this.store.findAll('interface'),
    });
  },
});
