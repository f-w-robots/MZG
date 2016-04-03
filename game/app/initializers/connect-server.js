var Socket = Ember.Object.extend({
  openSocket() {
    var socket;
    var self = this;
    var interval = setInterval(function() {
      if(socket && socket.readyState === socket.OPEN) {
        self.set('socket', socket);

        clearInterval(interval);

        socket.onopen = function (event) {

        };

        socket.onmessage = function (event) {
          var data = JSON.parse(event.data);
          var prefix = Object.keys(data)[0];
          data = data[prefix];
          self.latestMessages[prefix] = data[prefix];
          if(!self.onMessageListeners[prefix]) {
            return;
          }
          $.each(self.onMessageListeners[prefix], function(i, func) {
            func['func'].apply(func['context'], [data]);
          });
        };

        socket.onerror = function (event) {
          $.each(self.onErrorCallbacks, function(i, func) {
            func['func'].apply(func['context']);
          });
        };

        socket.onclose = function (event) {
          $.each(self.onCloseCallbacks, function(i, func) {
            func['func'].apply(func['context']);
          });
        };

        return;
      } else {
        socket = new WebSocket("ws://" + location.hostname + ":2500/group/communicate/game");
      }
    }, 1000);
  },

  init() {
    this.onMessageListeners = {};
    this.latestMessages = {};
    this.onErrorCallbacks = [];
    this.onCloseCallbacks = [];
    this.openSocket();
  },

  addOnMessage(prefix, func, context) {
    if(!this.onMessageListeners[prefix]) {
      this.onMessageListeners[prefix] = [];
    }
    this.onMessageListeners[prefix].push({func: func, context: context});
    if(this.latestMessages[prefix]) {
      func.apply(context, [this.latestMessages[prefix]]);
    }
  },

  addOnClose(func, context) {
    this.onErrorCallbacks.push({func: func, context: context});
  },

  addOnError(func, context) {
    this.onCloseCallbacks.push({func: func, context: context});
  },

  reserveBug: function(device) {
    this.get('socket').send(JSON.stringify({device: device}));
  },

  commit: function(commandList) {
    this.get('socket').send(JSON.stringify({commit: commandList}));
  },
});

export function initialize() {
  Ember.Socket = Socket.create({});
}

export default {
  name: 'connect-server',
  initialize
};
