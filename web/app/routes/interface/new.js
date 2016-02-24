import Ember from 'ember';

export default Ember.Route.extend({
  controllerName: 'interfaces',

  model() {
    return this.store.createRecord('interface', {});
  },

  renderTemplate() {
    this.render('interface.edit');
  },
});
