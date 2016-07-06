import Ember from 'ember';

export default Ember.Component.extend({
  store: Ember.inject.service('store'),
  modelName: null,

  actions: {
    add() {
      var record = this.get('store').createRecord('algorithm', {name:'', algorithm: ''});
      record.save().then(function(record) {
        this.set('device.algorithmId', record.get('id'));
      }.bind(this));
      this.set('record', record);
      this.set('model', record);
    },

    save() {
      this.set('record', null);
    },

    delete() {
      this.get('model').deleteRecord();
      this.get('model').save();
      this.set('model', null);
    },
  }
});
