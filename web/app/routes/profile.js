import Ember from 'ember';

export default Ember.Route.extend({
  setupController: function(controller, model) {
   this._super(controller, model);
   if(model.get('avatarUrl')) {
     controller.set('defaultAvatarUrl', model.get('avatarUrl'));
   } else {
     controller.set('defaultAvatarUrl', "/images/blank-profile.png");
   }
 },

  beforeModel: function(transition) {
    this.store.findRecord('user', 'current').then(function(user) {
      if(!user.get('authorized')) {
        this.transitionTo('index');
      }
    }.bind(this), function() {
      this.transitionTo('index');
    }.bind(this));
  },

  model() {
    var supportedPorviders = ['github'];
    var user = this.store.findRecord('user', 'current');
    user.then(function(user) {
      user.set('providersStatus', []);
      $.each(supportedPorviders, function(i, provider) {
        var status = user.get('providers').indexOf(provider) > -1
        user.get('providersStatus').push({name: provider, status: status})
      })
    },function() {
      // return
    });

    return user;
  }
});
