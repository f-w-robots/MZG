import Ember from 'ember';

export default Ember.Component.extend({
  onInit: function() {
    this.set('commandList', []);

    Ember.Socket.addOnMessage('response', this.updateCommand, this);
    Ember.Socket.addOnMessage('commit', this.commitLock, this);
  }.on('init'),

  updateCommand: function(response) {
    if(response === 'wait') {
      this.$('.command.btn-warning').first().removeClass('btn-warning').addClass('btn-success');
    }
    if(response === 'crash') {
      this.$('.command.btn-warning').first().removeClass('btn-warning').addClass('btn-danger');
    }
  },

  commitLock: function(commit) {
    if(commit === 'lock') {
      this.$('.commit-block').css({"background-color": "black"});
    } else {
      this.$('.commit-block').css({"background-color": "white"});
    }
  },

  actions: {
    command: function(cmd) {
      this.get('commandList').push(cmd);
      this.set('commandList', this.get('commandList').slice());
    },

    commit: function() {
      Ember.Socket.commit(this.get('commandList'));
    }
  },
});
