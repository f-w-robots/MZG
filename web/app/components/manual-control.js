import Ember from 'ember';

export default Ember.Component.extend({
  //TODO - inject service
  dm: Ember.getDMSocket(),
  store: Ember.inject.service('store'),
  connecteDevices: Ember.computed.alias('dm.devices'),
  errorDeviceManager: Ember.computed.alias('dm.error'),

  didInsertElement: function() {
    this.get('dm').updateDevices();
  },

  refreshDeviceState: function() {
    this.get('devices').find(function(device) {
      if(this.get('connecteDevices') && this.get('connecteDevices').indexOf(device.get('hwid')) > -1) {
        device.set('online', true);
      } else {
        device.set('online', false);
      }
    }, this)
  }.observes('connecteDevices'),

  actions: {
    createDevice: function() {
      var device = this.get('store').createRecord('device', {hwid: 'NONAME'})
      this.actions.selectDevice.apply(this, [device]);
    },

    selectDevice: function(device) {
      if(this.get('currentDeivce')) {
        this.set('currentDeivce.active', null);
      }
      device.set('active', true);

      this.set('controlUrl', null)
      if(this.get('currentDeivce.hwid') == device.get('hwid') ) {
        this.set('currentDeivce', null);
      } else {
        this.set('currentDeivce', device);
      }
    },

    killDevice: function(device) {
      this.get('dm').killDevice(device.get('hwid'));
    },

    controlDevice: function(device) {
      this.set('currentDeivce', null);
      this.set('controlUrl', location.protocol + '//'
        + location.hostname + ':3900/' + device.get('hwid'));
    },
  },
});
