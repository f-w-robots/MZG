import DS from 'ember-data';

export default DS.Model.extend({
  info: DS.attr('string'),
  code: DS.attr('string'),
  name: DS.attr('string'),
});
