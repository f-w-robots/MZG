import DS from 'ember-data';

export default DS.JSONAPIAdapter.extend({
  host: 'http://localhost:2600',
  namespace: 'api/v1',
});
