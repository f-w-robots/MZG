import Ember from 'ember';

export default Ember.Controller.extend({
  dm: Ember.inject.service('devices-manager'),
  store: Ember.inject.service('store'),
  connecteDevices: Ember.computed.alias('dm.devices'),
  errorDeviceManager: Ember.computed.alias('dm.error'),

  didInsertElement: function() {
    this.get('dm').updateDevices();
  },

  refreshDeviceState: function() {
    this.get('model.devices').find(function(device) {
      if(this.get('connecteDevices') && this.get('connecteDevices').indexOf(device.get('hwid')) > -1) {
        device.set('online', true);
      } else {
        device.set('online', false);
      }
    }, this);
  }.observes('connecteDevices'),

  actions: {
    createDevice: function() {
      this.transitionToRoute('/devices/new');
    },

    selectDevice: function(device) {
      this.transitionToRoute('/devices/' + device.get('id'));
    },

    killDevice: function(device) {
      this.get('dm').killDevice(device.get('hwid'));
    },
  },
});
