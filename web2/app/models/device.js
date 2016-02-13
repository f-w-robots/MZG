import DS from 'ember-data';

export default DS.Model.extend({
  manual: DS.attr('boolean'),
  hwid: DS.attr('string'),
  algorithmId: DS.attr('string'),
  interfaceId: DS.attr('string'),
});
