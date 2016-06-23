import Ember from 'ember';

export default Ember.Controller.extend({
  getUrlParameter: function getUrlParameter(sParam) {
    var sPageURL = decodeURIComponent(window.location.search.substring(1)),
        sURLVariables = sPageURL.split('&'),
        sParameterName,
        i;

    for (i = 0; i < sURLVariables.length; i++) {
        sParameterName = sURLVariables[i].split('=');

        if (sParameterName[0] === sParam) {
            return sParameterName[1] === undefined ? true : sParameterName[1];
        }
    }
  },

  setup: function() {
    if(this.getUrlParameter('error')) {
      this.set('error', this.getUrlParameter('error'));
    }
  }.on('init'),

  actions: {
    vkontakte: function() {
      location.replace(location.protocol + "//" + location.hostname + ":2600/auth/vkontakte")
    },

    github: function() {
      location.replace(location.protocol + "//" + location.hostname + ":2600/auth/github")
    },

    signin: function() {
      var self = this;
      Ember.$.post(location.protocol + "//" + location.hostname  + ":2600/auth/signin",
        { 'user': {login: this.get('username'), password: this.get('password')}},
        function(data, textStatus, xhr) {
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
        var j = JSON.parse(data.responseText)
        self.set('error', JSON.parse(data.responseText)["meta"]["errors"]);
      });
    },

    restore_password: function() {
      Ember.$.post(location.protocol + "//" + location.hostname  + ":2600/auth/forgot_password",
        {
          email: this.get('email'),
        },
        function(data, textStatus, xhr) {
          if(xhr.status == 201) {
            this.set('error', null);
            this.set('success', 'All right');
          } else {
            this.set('error', 'Error');
            this.set('success', null);
          }

        }.bind(this),
      ).fail(function(data, darta2, d3 ) {
      });
    },

    update_password: function() {
      Ember.$.post(location.protocol + "//" + location.hostname  + ":2600/auth/update_password",
        {
          password: this.get('password'),
          password_confirmation: this.get('password_confirmation'),
          key: this.getUrlParameter('key'),
        },
        function(data, textStatus, xhr) {
          if(xhr.status == 201) {
            this.set('error', null);
            this.set('success', 'All right');
          } else {
            this.set('error', 'Error');
            this.set('success', null);
          }

        }.bind(this),
      ).fail(function(data, darta2, d3 ) {
      });
    },
  },
});
