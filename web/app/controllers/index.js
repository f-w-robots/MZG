import Ember from 'ember';

export default Ember.Controller.extend({
  actions: {
    vkontakte: function() {
      location.replace("http://" + location.hostname + ":2600/auth/vkontakte")
    },

    github: function() {
      location.replace("http://" + location.hostname + ":2600/auth/github")
    },

    signin: function() {
      var self = this;
      Ember.$.post(location.protocol + "//" + location.hostname  + ":2600/auth/signin",
        { 'user': {username: this.get('username'), password: this.get('password')}},
        function(data, textStatus, xhr) {
          console.log(xhr.status);
          if(xhr.status == 201) {
            location.replace(location.origin);
          } else {
            self.set('error', 'Wrong username or password');
          }
        }
      ).fail(function() {
        self.set('error', 'Wrong username or password');
      });
    },

    signup: function() {
      var self = this;
      Ember.$.post(location.protocol + "//" + location.hostname  + ":2600/auth/signup",
        {
          'user':
            {
              email: this.get('email'),
              password: this.get('password'),
              password_confirmation: this.get('password_confirmation'),
            }
        },
        function(data, textStatus, xhr) {
          location.replace(location.origin);
        },
      ).fail(function(data, darta2, d3 ) {
        console.log(data.responseText);
        var j = JSON.parse(data.responseText)
        console.log(j);
        self.set('error', JSON.parse(data.responseText)["meta"]["errors"]);
      });
    },

    restore_password: function() {
      // TODO
    }

  }
});
