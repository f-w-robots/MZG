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
      var target = null;
      this.get('options').find(function(i){
        if(this.get('device.algorithm.id') === i.get('id')) {
          target = i;
        }
      }, this);
      target.deleteRecord();
      target.save();
      this.set('model', null);
      this.set('device.algorithm', null);
    },

    selectAlgorithm: function(algorithmId) {
      var target = null;
      this.get('options').find(function(i){
        if(algorithmId === i.get('id')) {
          target = i;
        }
      }, this);
      this.set('device.algorithm', target);
    },
  }
});
