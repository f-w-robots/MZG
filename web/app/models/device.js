import DS from 'ember-data';

export default DS.Model.extend({
  manual: DS.attr('boolean'),
  hwid: DS.attr('string'),
  group: DS.attr('string'),
  algorithmId: DS.attr('string'),
  interfaceId: DS.attr('string'),
  proxyId:  DS.attr('string'),
  icon: DS.attr(),
  useProxy: DS.attr('boolean'),
  proxyId: DS.attr('string'),
});
