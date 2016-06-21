import Ember from 'ember';

export default Ember.Route.extend({
  beforeModel: function(transition) {
    this.store.findRecord('user', 'current').then(function(user) {
      if(!user.get('authorized')) {
        this.transitionTo('index');
      }
    }.bind(this));
  },

  model() {
    var supportedPorviders = ['github'];
    var user = this.store.findRecord('user', 'current');
    user.then(function(user) {
        var unconnectedProviders = $.grep(supportedPorviders, function(provider) {
          if(user.get('providers').indexOf(provider) > -1) {
            return false;
          } else {
            return true;
          }
        })
        user.set('unconnectedProviders', unconnectedProviders);
    });

    return user;
  }
});
