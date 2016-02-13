import Ember from 'ember';

export default Ember.Controller.extend({
  actions: {
    deleteDevice: function(device) {
      console.log(device.deleteRecord());
      device.save();
    }
  }
});
