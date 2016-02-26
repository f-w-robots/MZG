import DS from 'ember-data';

export default DS.Model.extend({
  options: DS.attr({
    defaultValue() { return {}; }
  }),
  code: DS.attr('string'),
  name: DS.attr('string'),
});
