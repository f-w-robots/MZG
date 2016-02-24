import Ember from 'ember';

export default Ember.Controller.extend({
  actions: {
    deleteRecord: function(record) {
      record.deleteRecord();
      record.save();
    },
  }
});
