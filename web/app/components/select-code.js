import Ember from 'ember';

export default Ember.Component.extend({
  store: Ember.inject.service('store'),
  modelName: null,

  actions: {
    add() {
      this.set('addNew', true);
    },

    save() {
      // TODO - validation
      var record = {};
      record['name'] = this.get('newName');
      record[this.get('modelName')] = "";
      this.get('store').createRecord(this.get('modelName'), record).save().then(function() {
        this.set('addNew', null);
      }.bind(this), function() {

      }.bind(this))
    },

    delete() {
      this.get('model').deleteRecord();
      this.get('model').save();
      this.set('model', null);
    },
  }
});
