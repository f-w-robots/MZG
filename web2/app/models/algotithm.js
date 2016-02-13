import DS from 'ember-data';

export default DS.Model.extend({
  id: DS.attr('string'),
  algorithm: DS.attr('string'),
});
