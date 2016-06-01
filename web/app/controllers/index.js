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

            self.set('success', true);
            location.replace(location.origin);
          } else {
            self.set('success', false);
            self.set('error', true);
          }
        },
      );
      // location.reload();
    },
  }
});
