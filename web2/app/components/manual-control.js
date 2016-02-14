import Ember from 'ember';

export default Ember.Component.extend({
   currentHost: function(port) {
    return location.protocol + '//' + location.hostname + ':' + port;
  },

  didInsertElement: function() {
      Ember.$.get(this.currentHost('2500') + '/devices/list/manual', function( data ) {
        Ember.$.each(Ember.$.parseJSON(data)["keys"], function(i, key) {
          Ember.$('#selectList').append("<option selected>" + key + "</option>");
        });
      });
  },

  actions: {
    select: function() {
      var deviceId = Ember.$('#selectList').find(":selected").text();
      Ember.$('.controlBlock').html('<iframe src="' + this.currentHost('3900') + '/'+ deviceId + '"  width="400" height="500"></iframe>');
    }
  },
});
