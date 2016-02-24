import Ember from 'ember';
import config from './config/environment';

const Router = Ember.Router.extend({
  location: config.locationType
});

Router.map(function() {
  this.route('devices', function() {
    this.route('new');
    this.route('edit', { path: '/edit/:device_id' });
  });

  this.route('interface', function() {
    this.route('new');
    this.route('edit', { path: '/edit/:interface_id' });
  });

  this.route('algorithm', function() {
    this.route('new');
    this.route('edit', { path: '/edit/:algorithm_id' });
  });
  this.route('settings');
  this.route('admin');
});

export default Router;
