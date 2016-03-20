import Ember from 'ember';

export default Ember.Component.extend({
  onInit: function() {
    Ember.Socket.addOnMessage('info', this.updateInfo, this)
    this.updateStatus('connecting');
  }.on('init'),

  updateInfo: function(data) {
    this.checkStatus(data);

    data['timeout'] = Math.round(data['timeout']);
    if(!data['timeout'] < 0)
      data['timeout'] = 0;
    this.set('timeout', data['timeout']);
    this.set('round', data['round']);
    this.set('rounds_total', data['rounds_total']);
    this.set('finish', data['finish']);
    this.set('prepare', data['prepare']);
  },

  checkStatus: function(data) {
    if(data['prepare'])
      this.updateStatus('prepare');
    else
      if(data['finish'])
        this.updateStatus('finish');
      else
        this.updateStatus('play');
  },

  updateStatus: function(status) {
    if(status == 'connecting') {
      this.set('statusClass', 'alert-info');
      this.set('status', 'Connection');
    }
    if(status == 'finish') {
      this.set('statusClass', 'alert-success');
      this.set('status', 'Game Finish!')
    }
    if(status == 'play') {
      this.set('statusClass', 'alert-warning');
      this.set('status', 'Play')
    }
    if(status == 'prepare') {
      this.set('statusClass', 'alert-info');
      this.set('status', 'Please, select devices')
    }
  },
});
