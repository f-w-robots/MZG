import Ember from 'ember';

export default Ember.Component.extend({
  onInit: function() {
    Ember.Socket.addOnMessage('info', this.updateInfo, this)
  }.on('init'),

  updateInfo: function(data) {
    data['timeout'] = Math.round(data['timeout']);
    if(!data['timeout'] < 0)
      data['timeout'] = 0;
    this.set('timeout', data['timeout']);
    this.set('round', data['round']);
    this.set('rounds_total', data['rounds_total']);
    this.set('finish', data['finish']);
  }
});
