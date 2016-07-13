import Ember from 'ember';
import config from './config/environment';

const Router = Ember.Router.extend({
  location: config.locationType
});

Router.map(function() {
  this.route('admin', function() {
    this.route('new');
    this.route('edit', { path: '/edit/:group_id' });
  });
  this.route('profile', function() {
    this.route('delete');
    this.route('account');
    this.route('profile');
  });
  this.route('signin');
  this.route('signup');
  this.route('forgot_password');
  this.route('update_password');
  this.route('delete_profile');
  this.route('devices', function() {
    this.route('device', {path: '/:device_id'}, function() {
      this.route('builder');
      this.route('control');
      this.route('program');
      this.route('settings');
    });
  });
});

export default Router;
