import Ember from 'ember';

export default Ember.Route.extend({
  controllerName: 'devices',

  setupController: function(controller, model) {
    controller.set('algorithms', this.store.findAll('algorithm'));
    controller.set('interfaces', this.store.findAll('interface'));
    controller.set('model', model);
  },

  model() {
    return {hwid: '', manual: false};
  },

  renderTemplate() {
    this.render('devices.edit');
  },
});
