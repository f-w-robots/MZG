import Ember from 'ember';

export default Ember.Route.extend({
  controllerName: 'algorithms',

  model() {
    return this.store.createRecord('algorithm', {});
  },

  renderTemplate() {
    this.render('algorithm.edit');
  },
});
