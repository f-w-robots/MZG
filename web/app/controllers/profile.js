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
          var errors = [];
          this.set('errors', errors);
          $.each(this.get('model.errors'), function(i, el) {
            if(el == 'err1')
              errors.push('Passwords not coincides')
            if(el == 'err2')
              errors.push('Password is short')
          })
        }
      }.bind(this));
    },

    connect: function() {
      location.replace(location.protocol + "//" + location.hostname + ":2600/auth/github")
    }
  }
});
