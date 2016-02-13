import Ember from 'ember';

export default Ember.Controller.extend({
  actions: {
    saveRecord: function() {
      console.log(this.get('model').save());
    }
  }
});
