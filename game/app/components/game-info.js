import Ember from 'ember';

export default Ember.Component.extend({
  didInsertElement: function() {
    Ember.Socket.addOnMessage('info', this.updateInfo, this)
  },

  updateInfo: function(data) {
    console.log(data);
    this.set('timeout', data['timeout']);
    this.set('round', data['round']);
    this.set('rounds_total', data['rounds_total']);
  }
});
