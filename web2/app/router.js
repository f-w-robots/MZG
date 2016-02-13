import Ember from 'ember';
import config from './config/environment';

const Router = Ember.Router.extend({
  location: config.locationType
});

Router.map(function() {
  this.route('devices', function() {
    this.route('new');
    this.route('edit', { path: '/devices/edit/:device_id' });
  });
});

export default Router;
