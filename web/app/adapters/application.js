import DS from 'ember-data';

import ENV from '../config/environment';

var adapter;

if(ENV.environment !== 'test') {
  adapter = DS.JSONAPIAdapter.extend({
    host: location.protocol + '//api.' + location.hostname,
    namespace: 'api/v1',
  });
} else {
  adapter = DS.JSONAPIAdapter.extend({
    namespace: 'api/test',
  });
}

export default adapter;
