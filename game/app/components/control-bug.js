import Ember from 'ember';

export default Ember.Component.extend({
  onInit: function() {
    this.set('commandList', []);
  }.on('init'),

  actions: {
    command: function(cmd) {
      this.get('commandList').push(cmd);
      this.set('commandList', this.get('commandList').slice());
    },
  },
});
