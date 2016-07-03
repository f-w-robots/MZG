import Ember from 'ember';

export default Ember.Mixin.create({
  socket: false,
  devices: null,
  url: null,

  openSocket: function() {
    var socket = new WebSocket(this.get('url'));
    this.set('socket', socket);

    socket.onopen = function (event) {
      this.set('wasOpen', true);
      $.each(this.onOpenCallbacks, function(i, func) {
        func['func'].apply(func['context']);
      });
    }.bind(this);

    socket.onmessage = function (event) {
      var data = JSON.parse(event.data);
      var prefix = Object.keys(data)[0];
      data = data[prefix];
      this.latestMessages[prefix] = data;
      if(!this.onMessageListeners[prefix]) {
        console.log(prefix, data);
        return;
      }
      $.each(this.onMessageListeners[prefix], function(i, func) {
        func['func'].apply(func['context'], [data]);
      });
    }.bind(this);

    socket.onerror = function (event) {
      $.each(this.onErrorCallbacks, function(i, func) {
        func['func'].apply(func['context']);
      });
    }.bind(this);

    socket.onclose = function (event) {
      $.each(this.onCloseCallbacks, function(i, func) {
        func['func'].apply(func['context']);
      });
      setTimeout(function() {
        this.openSocket();
      }.bind(this), 1000);
    }.bind(this);
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
