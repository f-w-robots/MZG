import DS from 'ember-data';

export default DS.JSONAPIAdapter.extend({
  host: location.protocol + '//' + location.hostname + ':' + 2600,
  namespace: 'api/v1',
});
