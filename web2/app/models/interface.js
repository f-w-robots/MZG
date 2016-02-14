import DS from 'ember-data';

export default DS.Model.extend({
  interface_id: DS.attr('string'),
  interface: DS.attr('string'),
});
