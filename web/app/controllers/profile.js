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
          this.set('errors', this.get('model.errors'));
        }
      }.bind(this));
    },

    connect: function() {
      location.replace(location.protocol + "//" + location.hostname + ":2600/auth/github")
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
    }
  }
});
