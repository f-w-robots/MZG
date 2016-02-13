import Ember from 'ember';

export default Ember.Controller.extend({
  actions: {
    saveRecord: function() {
      if(this.get('model').store) {
        this.get('model').save();
      } else {
        this.store.createRecord('device', this.get('model')).save();
      }
    },
  }
});
