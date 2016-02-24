import DS from 'ember-data';

export default DS.Model.extend({
  algorithmId: DS.attr('string'),
  algorithm: DS.attr('string'),
});
