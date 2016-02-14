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
});

export default Router;
