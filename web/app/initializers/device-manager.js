import abstractSocket from '../mixins/abstract-socket';

var Socket = Ember.Object.extend(abstractSocket, {
  devices: null,
  error: null,

  init() {
    this.set('url', 'ws://' + location.hostname + ':2500/devices/manage')
    this.onInit()
    this.addOnMessage('devices', function(data) {
      this.set('devices', data);
    }, this);

    this.addOnOpen(function(){
      this.set('errorDeviceManager', false);
    }, this);

    var onError = function() {
      this.set('errorDeviceManager', true);
      this.set('devices', null);
    }

    this.addOnError(onError, this);
    this.addOnClose(onError, this);
  },

  updateDevices() {
    this.sendDirect('devices');
  },

  killDevice(hwid) {
    this.sendDirect("kill_device:" + hwid);
  },

  updateCode(hwid, code) {
    this.sendDirect("{\"restart\":\"" + hwid + "\",\"code\":\"" + code + "\"}")
  }
});

export function initialize() {
  var dmSocket = Socket.create({});
  Ember.getDMSocket = function() {
    return dmSocket;
  }
}

export default {
  name: 'device-manager',
  initialize
};
