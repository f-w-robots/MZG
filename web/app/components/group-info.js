import Ember from 'ember';

export default Ember.Component.extend({
  info: null,
  url: null,

  currentHost: function(port) {
    return location.protocol + '//' + location.hostname + ':' + port;
  },

  didInsertElement: function() {
    var self = this;

    // setInterval(function() {
      Ember.$.get(self.currentHost('2500') + '/group/info/game', function(data) {
        self.set('info', data);
      }).fail(function() {
        self.set('info', 'group not runned');
      });
    // }, 1000);
  },
});
