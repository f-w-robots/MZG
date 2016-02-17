import Ember from 'ember';

export default Ember.Controller.extend({
  setModels() {
    this.set('algorithms', this.store.findAll('algorithm'));
    this.set('interfaces', this.store.findAll('interface'));
  },

  actions: {
    saveRecord() {
      this.get('model').save();
    },

    selectAlgorithm(algorithm) {
      this.get('model').set('algorithmId', algorithm);
    },

    selectInterface(interfac) {
      this.get('model').set('interfaceId', interfac);
    },
  },
});
