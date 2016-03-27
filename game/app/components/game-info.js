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
    'device': {
      'class': 'alert-warning',
      'text': 'Wait to start the game',
    }
  },

  onInit: function() {
    Ember.Socket.addOnMessage('info', this.updateInfo, this)
    this.set('status', 'connecting');
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
    if(data['prepare']) {
      if(!this.get('device'))
        this.set('status', 'prepare');
    } else {
      if(data['finish'])
        this.set('status', 'finish');
      else
        this.set('status', 'play');
      }
  },

  onStatusChange: function() {
    var status = this.get('status');
    this.set('statusClass', this.get('statusHash')[status]['class']);
    this.set('statusText',  this.get('statusHash')[status]['text']);
  }.observes('status'),

  onDeviceChange: function() {
    if(this.get('device'))
      this.set('status', 'device')
  }.observes('device'),

  displayStats: function(){
    var status = this.get('status');
    return !(status == 'connecting' || status == 'finish');
  }.property('status'),
});
