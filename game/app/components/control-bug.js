import Ember from 'ember';

export default Ember.Component.extend({
  allowCommit: true,
  commandList: [],

  onInit: function() {
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
      this.set('allowCommit', false);
    } else {
      this.set('allowCommit', true);
      this.set('commandList', []);
    }
  },

  allowCommitObserver: function() {
    if(this.get('allowCommit')) {
      this.$('.commit-block').css({"background-color": "white"});
    } else {
      this.$('.commit-block').css({"background-color": "black"});
    }
  }.observes('allowCommit'),

  actions: {
    command: function(cmd) {
      if(this.get('allowCommit')) {
        this.get('commandList').push(cmd);
        this.set('commandList', this.get('commandList').slice());
      }
    },

    commit: function() {
      Ember.Socket.commit(this.get('commandList'));
    }
  },
});
