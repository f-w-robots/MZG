import Ember from 'ember';

export default Ember.Route.extend({
  controllerName: 'admin',

  setupController: function(controller, model) {
    this._super(controller, model);
    controller.set('fields', ['rounds', 'timeout']);
  },

  model(params) {
    return this.store.findRecord('group', params.group_id);
  },

  renderTemplate() {
    this.render('admin.edit');
  },
});
