import Ember from 'ember';

export default Ember.Component.extend({
  statusHash: {
    'connecting': {
      'class': 'alert-info',
      'text': 'Connection to Game server',
    },
    'finish': {
      'class': 'alert-success',
      'text': 'Game Finish!',
    },
    'play': {
      'class': 'alert-warning',
      'text': 'Play',
    },
    'prepare': {
      'class': 'alert-info',
      'text': 'Please, select devices',
    },
  },

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
    this.set('status', status);
    this.set('statusClass', this.get('statusHash')[status]['class']);
    this.set('statusText',  this.get('statusHash')[status]['text']);
  },

  displayStats: function(){
    var status = this.get('status');
    return !(status == 'connecting' || status == 'finish');
  }.property('status'),
});
