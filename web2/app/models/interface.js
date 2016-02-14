import DS from 'ember-data';

export default DS.Model.extend({
  interfaceId: DS.attr('string'),
  interface: DS.attr('string'),
});
