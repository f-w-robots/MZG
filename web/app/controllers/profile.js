import Ember from 'ember';

export default Ember.Controller.extend( {

  actions: {
    save: function() {
      this.get('model').save().then(function(result) {
        if(result.get('errors').length == 0) {
          this.set('success', true);
          this.set('errors', false);
        } else {
          this.set('errors', true);
          this.set('success', false);
        }
      }.bind(this));
    },
  }
});
