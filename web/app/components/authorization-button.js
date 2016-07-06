import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'a',

  actions: {
    logout: function() {
      location.replace("http://" + location.hostname + ":2600/auth/logout");
    }
  }
});
