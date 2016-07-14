import DS from 'ember-data';

export default DS.Model.extend({
  hwid: DS.attr('string'),
  algorithmId: DS.attr('string'),
  icon: DS.attr(),
  errors: DS.attr({}),
  buildId: DS.attr('string'),
});
