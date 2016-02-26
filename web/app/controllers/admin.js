import Ember from 'ember';

export default Ember.Controller.extend({
  modelFieldsObserver: function() {
    if(!this.get('model.fields'))
      return
    var fields = this.get('model.fields').split(',');

    fields = fields.map(function(field) {
      return field.trim();
    }).reject(function(field) {
      if(field.length > 0)
        return false;
      else
        return true;
    });

    this.set('fields', fields);
  }.observes('model.fields'),

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
