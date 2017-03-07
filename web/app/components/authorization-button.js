import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'a',

  actions: {
    logout: function() {
      location.replace("http://api." + location.hostname + "/auth/logout");
    }
  }
});
