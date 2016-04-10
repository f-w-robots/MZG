import Ember from 'ember';

export default Ember.Component.extend({
  devices: null,
  url: null,
  socket: null,

  currentHost: function(port) {
    return 'ws://' + location.hostname + ':' + port;
  },

  webSocketUrl: function() {
    return this.currentHost(2500) + "/devices/list/manual";
  },

  didInsertElement: function() {
    var self = this;

    socket = Ember.webSockets.socket(this.webSocketUrl())

    if(!socket) {
      var socket = new WebSocket(this.currentHost(2500) + "/devices/list/manual");
      Ember.webSockets.socket(this.webSocketUrl(), socket);

      socket.onopen = function() {

      };

      socket.onclose = function(event) {

      };

      socket.onerror = function(error) {

      };
    }

    socket.onmessage = function(event) {
      if(self.get('_state') == 'inDOM') {
        self.set('devices', Ember.$.parseJSON(event.data)["keys"]);
      }
    };

    if(socket.readyState == 1)
      socket.send('request');
  },

  actions: {
    select: function(deviceId) {
      this.set('url', this.currentHost('3900') + '/'+ deviceId);
    },
  },
});
