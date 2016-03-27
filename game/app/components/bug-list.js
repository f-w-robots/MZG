import Ember from 'ember';

export default Ember.Component.extend({
  onInit: function() {
    Ember.Socket.addOnMessage('devices', this.updateInfo, this)
  }.on('init'),

  updateInfo: function(data) {
    this.set('devices', data);
  },

  actions: {
    select: function(device) {
      this.set('controller.device', device);
    },
  }

});
