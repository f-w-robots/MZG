import Ember from 'ember';

export default Ember.Component.extend({
  devices: null,
  url: null,
  socket: null,
  errorDeviceManager: false,

  currentHost: function(port) {
    return location.protocol + '//' + location.hostname + ':' + port;
  },

  setup: function() {
    Ember.DMSocket.addOnMessage('devices', function(data) {
      if(this.get('_state') == 'inDOM') {
        this.set('manual_devices', data["manual"]);
        this.set('algorithm_devices', data["algorithm"]);
      }
    }, this);

    Ember.DMSocket.addOnOpen(this.openDM, this);
    Ember.DMSocket.addOnError(this.errorDM, this);
    Ember.DMSocket.addOnClose(this.errorDM, this);
  }.on('init'),

  didInsertElement: function() {
    var socket = Ember.DMSocket.getSocket();

    Ember.DMSocket.sendDirect('devices');
  },

  errorDM: function() {
    if(this.get('_state') == 'inDOM') {
      this.set('errorDeviceManager', true);
    }
    this.set('manual_devices', []);
    this.set('algorithm_devices', []);
  },

  openDM: function() {
    if(this.get('_state') == 'inDOM') {
      Ember.DMSocket.sendDirect('devices');
      this.set('errorDeviceManager', false);
    }
  },

  actions: {
    select: function(deviceId) {
      this.set('url', this.currentHost('3900') + '/'+ deviceId);
    },
  },
});
