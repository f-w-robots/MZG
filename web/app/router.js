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
  });
  this.route('signin');
  this.route('signup');
  this.route('forgot_password');
  this.route('update_password');
  this.route('delete_profile');
});

export default Router;
