import Ember from 'ember';

export default Ember.Route.extend({
  controllerName: 'admin',

  model() {
    return this.store.createRecord('group', {});
  },

  renderTemplate() {
    this.render('admin.edit');
  },
});
