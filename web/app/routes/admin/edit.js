import Ember from 'ember';

export default Ember.Route.extend({
  controllerName: 'admin',

  model(params) {
    return this.store.findRecord('group', params.group_id);
  },

  renderTemplate() {
    this.render('admin.edit');
  },
});
