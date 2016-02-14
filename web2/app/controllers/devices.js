import Ember from 'ember';

export default Ember.Controller.extend({
  actions: {
    saveRecord: function() {
      var model = this.get('model');
      if(model.store) {
        model.save();
      } else {
        this.store.createRecord('device', model).save();
      }
    },

    selectAlgorithm(algorithm) {
      this.get('model').set('algorithmId', algorithm);
    },

    selectInterface(interfac) {
      this.get('model').set('interfaceId', interfac);
    },
  },
});
