import Ember from 'ember';

export default Ember.Component.extend({
  actions: {
    authorize: function() {
      location.replace("http://" + location.hostname + ":2600/auth/vkontakte")
    },
  }
});
