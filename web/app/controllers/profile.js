import Ember from 'ember';

export default Ember.Controller.extend( {
  actions: {
    save: function() {
      this.set('model.email', this.get('temp_email'));
      this.set('model.username', this.get('temp_username'));
      this.set('model.passwordConfirmation', this.get('temp_passwordConfirmation'));
      this.set('model.password', this.get('temp_password'));

      this.get('model').save().then(function(result) {
        if(result.get('errors').length == 0) {
          this.set('success', true);
          this.set('errors', false);
          this.set('edit', false);
          console.log('set');
        } else {
          this.set('errors', true);
          this.set('success', false);
          this.set('errors', this.get('model.errors'));
        }
      }.bind(this));

    },

    edit: function() {
      this.set('temp_email', this.get('model.email'));
      this.set('temp_username', this.get('model.username'));
      this.set('edit', true);
    },

    reject: function() {
      this.set('edit', false);
    },

    connect: function() {
      location.replace(location.protocol + "//" + location.hostname + ":2600/auth/github")
    },

    disconnect: function() {
      location.replace(location.protocol + "//" + location.hostname + ":2600/auth/github/disconnect")
    },

    delete: function() {
      if(this.get('model.username') == this.get('username')) {
        this.get('model').deleteRecord();
        this.get('model').save().then(function() {
          var newLocation = location.protocol + "//" + location.hostname;
          if(location.port.length > 0) {
            newLocation = newLocation + ':' + location.port;
          }
          location.replace(newLocation);
        });
      } else {
        this.set('error', 'Usernames is not coincides')
      }
    },
  }
});
