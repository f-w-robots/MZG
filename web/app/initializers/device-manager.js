import abstractSocket from '../mixins/abstract-socket';

var Socket = Ember.Object.extend(abstractSocket, {
  devices: null,
  error: null,
  badCode: null,
  output: Ember.RSVP.hash({}),

  init() {
    this.set('url', 'ws://' + location.hostname + ':2500/devices/manage')
    this.onInit()
    this.addOnMessage('devices', function(data) {
      this.set('devices', data);
    }, this);

    this.addOnMessage('bad_code', function(data) {
      this.set('badCode', true);
    }, this);

    this.addOnMessage('output', function(data) {
      var self = this;
      $.each(Object.keys(data), function(i, key) {
        var output = self.get('output.' + key);
        if(!output) { output = ''}
        self.set('output.' + key, output + data[key]);
      });
    }, this);

    this.addOnOpen(function(){
      this.set('error', false);
    }, this);

    var onError = function() {
      this.set('error', true);
      this.set('devices', null);
    }

    this.addOnError(onError, this);
    this.addOnClose(onError, this);
  },

  updateDevices() {
    this.sendDirect(JSON.stringify({'list':''}));
  },

  updateDevice(hwid) {
    this.sendDirect(JSON.stringify({'update': hwid}));
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
