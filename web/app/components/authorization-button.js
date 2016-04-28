import Ember from 'ember';

export default Ember.Component.extend({
  actions: {
    login: function() {
      location.replace("http://" + location.hostname + ":2600/auth/vkontakte")
    },

    logout: function() {
      location.replace("http://" + location.hostname + ":2600/auth/logout")
    }
  }
});
