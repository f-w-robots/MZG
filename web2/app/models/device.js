import DS from 'ember-data';

export default DS.Model.extend({
  manual: DS.attr('boolean'),
  hwid: DS.attr('string'),
  algorithm_id: DS.attr('string'),
  interface_id: DS.attr('string'),
});
