import Ember from 'ember';
import authRouteMixin from '../mixins/auth-route';

export default Ember.Route.extend(authRouteMixin, {
  setupController: function(controller, model) {
    this._super(controller, model);
    if(model.get('avatarUrl')) {
      controller.set('defaultAvatarUrl', model.get('avatarUrl'));
    } else {
      controller.set('defaultAvatarUrl', "https://www.gravatar.com/avatar/" + md5(model.get('email')));
    }
  },

  model() {
    var supportedPorviders = ['github'];
    var user = this.store.findRecord('user', 'current');
    user.then(function(user) {
      user.set('providersStatus', []);
      $.each(supportedPorviders, function(i, provider) {
        var status = user.get('providers').indexOf(provider) > -1;
        user.get('providersStatus').push({name: provider, status: status});
      });
    },function() {
      // return
    });
    return user;
  }
});
