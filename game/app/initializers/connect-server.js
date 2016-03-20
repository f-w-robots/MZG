var Socket = Ember.Object.extend({
  openSocket() {
    var socket;
    var self = this;
    socket = new WebSocket("ws://" + location.hostname + ":2500/group/communicate/game");

    socket.onopen = function (event) {
    };

    socket.onmessage = function (event) {
      console.log('onmsg');
      var data = JSON.parse(event.data);
      var prefix = Object.keys(data)[0];
      data = data[prefix];
      if(!self.onMessageListeners[prefix])
        return;
      $.each(self.onMessageListeners['info'], function(i, func) {
        func['func'].apply(func['context'], [data]);
      })
    };

    socket.onerror = function (event) {

    };

    socket.onclose = function (event) {

    };
  },

  init() {
    this.onMessageListeners = {}
    this.openSocket();
  },

  addOnMessage(prefix, func, context) {
    if(!this.onMessageListeners[prefix])
      this.onMessageListeners[prefix] = [];
    this.onMessageListeners[prefix].push({func: func, context: context});
  }
});

export function initialize() {
  Ember.Socket = Socket.create({});
}

export default {
  name: 'connect-server',
  initialize
};
