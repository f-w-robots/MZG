import Ember from 'ember';

export default Ember.Mixin.create({
  socket: false,
  devices: null,
  url: null,

  openSocket: function() {
    var self = this;

    var socket = new WebSocket(this.get('url'));
    this.set('socket', socket);

    socket.onopen = function (event) {
      self.set('wasOpen', true);
      $.each(self.onOpenCallbacks, function(i, func) {
        func['func'].apply(func['context']);
      });
    };

    socket.onmessage = function (event) {
      var data = JSON.parse(event.data);
      var prefix = Object.keys(data)[0];
      data = data[prefix];
      self.latestMessages[prefix] = data;
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
      setTimeout(function() {
        self.openSocket();
      }, 1000);
    };
  },

  getSocket: function() {
    return this.get('socket');
  },

  onInit() {
    this.onMessageListeners = {};
    this.latestMessages = {};
    this.onErrorCallbacks = [];
    this.onCloseCallbacks = [];
    this.onOpenCallbacks = [];
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

  addOnOpen(func, context) {
    this.onOpenCallbacks.push({func: func, context: context});
  },

  addOnClose(func, context) {
    this.onErrorCallbacks.push({func: func, context: context});
  },

  addOnError(func, context) {
    this.onCloseCallbacks.push({func: func, context: context});
  },

  sendDirect(message) {
    var socket = this.get('socket');
    if(socket.readyState == 1) {
      socket.send(message);
    } else {
      var intervalId = setInterval(function () {
        if(socket.readyState == 1) {
          socket.send(message);
          clearInterval(intervalId);
        }
      }, 10);
    }
  },
});
