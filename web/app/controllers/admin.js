import Ember from 'ember';

export default Ember.Controller.extend({
  actions: {
    saveRecord: function() {
      this.get('model').save();
    },

    startGame: function() {
      Ember.$.post(location.protocol + '//' + location.hostname + ':' + '2500' + '/group/up/g')
    }
  }
});
