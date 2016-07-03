import Ember from 'ember';

export default Ember.Route.extend({
  controllerName: 'device',

  setupController: function(controller, model) {
    var algorithms = this.store.findAll('algorithm')
    controller.set('algorithms', algorithms)
    algorithms.then(function(algorithms) {
      controller.algorithmObserver();
    });
    if(model) {
      controller.set('devicesController.currentDeviceId', model.get('id'));
    }
    this._super(controller, model);
  },

  model(params) {
    if(params['device_id'] == 'new') {
      this.get('store').createRecord('device', {hwid: Math.round(Math.random()*100000).toString()}).save().then(function(device) {
        this.transitionTo('/devices/' + device.get('id'))
      }.bind(this));
    } else {
      var device = this.store.findRecord('device', params['device_id'])

      return device.then(function(device) {
        return device;
      }, function(device) {
        return null;
      })
    }
  }
});
