import Ember from 'ember';

export default Ember.Component.extend({
  devices: null,
  url: null,

   currentHost: function(port) {
    return location.protocol + '//' + location.hostname + ':' + port;
  },

  didInsertElement: function() {
    var self = this;
    Ember.$.get(this.currentHost('2500') + '/devices/list/manual', function(data) {
      self.set('devices', Ember.$.parseJSON(data)["keys"]);
    });
  },

  actions: {
    select: function(deviceId) {
      this.set('url', this.currentHost('3900') + '/'+ deviceId);
    },
  },
});
