import DS from 'ember-data';

export default DS.Model.extend({
  manual: DS.attr(),
  hwid: DS.attr(),
});
