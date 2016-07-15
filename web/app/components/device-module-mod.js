import Ember from 'ember';

export default Ember.Component.extend({
  actions: {
    delete(mod) {
      this.get('comp.mods').removeObject(mod)
    }
  }
});
