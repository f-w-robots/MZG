import Ember from 'ember';

export default Ember.Controller.extend({
  actions: {
    deleteRecord: function(record) {
      console.log(record.deleteRecord());
      record.save();
    },
  }
});
