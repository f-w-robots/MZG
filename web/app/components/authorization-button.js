import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'a',

  actions: {
    logout: function() {
      location.replace("http://" + location.hostname + "/auth/logout");
    }
  }
});
