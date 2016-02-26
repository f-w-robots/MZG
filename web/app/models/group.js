import DS from 'ember-data';

export default DS.Model.extend({
  options: DS.attr({
    defaultValue() { return {}; }
  }),
  fields: DS.attr('string'),
  code: DS.attr('string'),
  name: DS.attr('string'),
});
