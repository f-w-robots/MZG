import Ember from 'ember';

export default Ember.Route.extend({
  controllerName: 'devices',

  model() {
    return {hwid: '', manual: false};
  },

  renderTemplate() {
    this.render('devices.edit');
  },
});
