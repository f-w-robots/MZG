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

    signup: function() {
      var self = this;
      Ember.$.post(location.protocol + "//" + location.hostname  + ":2600/auth/signup",
        {
          'user':
            {
              username: this.get('username'),
              password: this.get('password'),
            }
        },
        function(data, textStatus, xhr) {
          console.log(xhr.status);
          if(xhr.status == 201) {
            self.set('success', true);
          } else {
            self.set('success', false);
            self.set('error', true);
          }
        },
      );
    },

  }
});
