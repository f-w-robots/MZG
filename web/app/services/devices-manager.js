import Ember from 'ember';
import abstractSocket from '../mixins/abstract-socket';

export default Ember.Service.extend(abstractSocket, {
  devices: null,
  error: null,
  output: Ember.RSVP.hash({}),

  init() {
    this.set('url', 'ws://hwapi' + location.hostname + '/devices/manage');
    this.onInit();
    this.addOnMessage('devices', function(data) {
      this.set('devices', data);
    }, this);

    this.addOnMessage('output', function(data) {
      $.each(Object.keys(data), function(i, key) {
        if(!this.get('output.' + key)) {
          this.set('output.' + key, []);
        }
        var out = data[key];
        var obj = {line: out[1]};
        if(out[0] === 'stdout') {
          obj['stdout'] = true;
        } else {
          obj['stderr'] = true;
        }

        this.get('output.' + key).push(Ember.Object.create(obj));
        var len = this.get('output.' + key).length;
        this.set('output.' + key, this.get('output.' + key).slice(len - 1000));
        this.set('outputUpdated', []);
      }.bind(this));
    }.bind(this), this);

    this.addOnOpen(function(){
      this.set('error', false);
    }, this);

    var onError = function() {
      this.set('error', true);
      this.set('devices', null);
    };

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
    this.sendDirect("{\"restart\":\"" + hwid + "\",\"code\":\"" + code + "\"}");
  }
});
