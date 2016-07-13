import Ember from 'ember';

export default Ember.Route.extend({
  controllerName: 'device',

  setupController: function(controller, model) {
    controller.set('activeLink', 'builder')
    this._super(controller, model);
  },
});
