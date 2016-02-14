import Ember from 'ember';

export default Ember.Controller.extend({
  actions: {
    saveRecord: function() {
      var model = this.get('model');
      if(model.store) {
        model.save();
      } else {
        this.store.createRecord('algorithm', model).save();
      }
    },
  }
});
