import Ember from 'ember';

import saveModelControllerMixin from '../mixins/save-model-controller';

export default Ember.Controller.extend(saveModelControllerMixin, {
  setup() {
    this.set('algorithms', this.store.findAll('algorithm'));
    this.set('interfaces', this.store.findAll('interface'));

    this.set('saveStatus', null);
  },

  actions: {
    selectAlgorithm(algorithm) {
      this.get('model').set('algorithmId', algorithm);
    },

    selectInterface(interfac) {
      this.get('model').set('interfaceId', interfac);
    },
  },
});
