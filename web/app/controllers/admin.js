import Ember from 'ember';

export default Ember.Controller.extend({
  actions: {
    saveRecord: function() {
      this.get('model').save();
    },

    runGroup: function() {
      Ember.$.post(location.protocol + '//' + location.hostname + ':' + '2500' + '/group/up/' + this.get('model.name'))
    },

    deleteRecord: function(record) {
      record.deleteRecord();
      record.save();
    },
  }
});
