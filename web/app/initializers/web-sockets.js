var WebSockets = Ember.Object.extend({
  sockets: {},

  socket: function(url, socket) {
    if(socket)
      return this.sockets[url] = socket;
    else
      return this.sockets[url];
  }
});

export function initialize() {
  Ember.webSockets = WebSockets.create({});
}

export default {
  name: 'connect-server',
  initialize
};
