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
        var all_devices = data["manual"].concat(data["algorithm"])
        if(all_devices.indexOf(this.get('selectedDeviceId')) < 0) {
          this.set('device', null);
          this.set('selectedDeviceId', null);
        }
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
      this.set('manual_devices', []);
      this.set('algorithm_devices', []);
    }
  },

  openDM: function() {
    if(this.get('_state') == 'inDOM') {
      Ember.DMSocket.sendDirect('devices');
      this.set('errorDeviceManager', false);
    }
  },

  actions: {
    select: function(deviceId) {
      this.set('url', null);
      if(this.get('selectedDeviceId') == deviceId) {
        this.set('device', null);
        this.set('selectedDeviceId', null);
      } else {
        var device;
        this.get('devices').find(function(d) {
          if(d.get('hwid') == deviceId)
            device = d
        });
        this.set('device', device);
        this.set('selectedDeviceId', deviceId);
      }
    },

    openControl: function(deviceId) {
      this.set('device', null);
      var url = this.currentHost('3900') + '/'+ deviceId;
      if(this.get('url') == url)
        this.set('url', null);
      else
        this.set('url', url);
    },


  },
});
