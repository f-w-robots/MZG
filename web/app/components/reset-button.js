import Ember from 'ember';

export default Ember.Component.extend({
  webSocketUrl: function() {
    return 'ws://' + location.hostname + ":2500/devices/list/manual";
  },

  actions: {
    kill: function() {
      Ember.DMSocket.sendDirect("kill_device:" + this.get('hwid'))
    }
  }
});
