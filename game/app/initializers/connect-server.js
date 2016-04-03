var Socket = Ember.Object.extend({
  wasOpen: false,

  openSocket() {
    var self = this;

    var socket = new WebSocket("ws://" + location.hostname + ":2500/group/communicate/game");
    this.set('socket', socket);

    socket.onopen = function (event) {
      self.set('wasOpen', true);
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
      if(!self.get('wasOpen')) {
        return;
      }
      $.each(self.onErrorCallbacks, function(i, func) {
        func['func'].apply(func['context']);
      });
    };

    socket.onclose = function (event) {
      if(!self.get('wasOpen')) {
        return;
      }
      $.each(self.onCloseCallbacks, function(i, func) {
        func['func'].apply(func['context']);
      });
    };
  },

  tryOpenSocket() {
    this.openSocket();

    var self = this;
    var interval = setInterval(function() {
      if(self.get('wasOpen')) {
        clearInterval(interval);
        return;
      }
      self.openSocket();
    }, 1000);
  },

  init() {
    this.onMessageListeners = {};
    this.latestMessages = {};
    this.onErrorCallbacks = [];
    this.onCloseCallbacks = [];
    this.tryOpenSocket();
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
