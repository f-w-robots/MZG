import Ember from 'ember';

export default Ember.Controller.extend({
  actions: {
    saveRecord: function() {
      this.get('model').save();
    },
  }
});
