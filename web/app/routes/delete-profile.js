import Ember from 'ember';
import authRouteMixin from '../mixins/auth-route';

export default Ember.Route.extend(authRouteMixin, {
  controllerName: 'profile',

  model() {
    return this.store.findRecord('user', 'current');
  }
});
