import Ember from 'ember';

export default Ember.Component.extend({
   currentHost: function(port) {
    return location.protocol + '//' + location.hostname + ':' + port
  },

  didInsertElement: function() {
      $.get(this.currentHost('2500') + '/devices/list/manual', function( data ) {
        $.each($.parseJSON(data)["keys"], function(i, key) {
          $('#selectList').append("<option selected>" + key + "</option>")
        });
      });
  },

  actions: {
    select: function() {
      var deviceId = $('#selectList').find(":selected").text();
      $('.controlBlock').html('<iframe src="' + this.currentHost('3900') + '/'
        + deviceId + '"  width="400" height="500"></iframe>')
    }
  },
});
