import DS from 'ember-data';

export default DS.JSONAPIAdapter.extend({
  host: location.protocol + '//' + location.hostname,
  namespace: 'api/v1',
});
