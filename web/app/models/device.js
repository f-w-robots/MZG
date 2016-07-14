import DS from 'ember-data';

export default DS.Model.extend({
  hwid: DS.attr('string'),
  icon: DS.attr(),
  errors: DS.attr({}),
  algorithm: DS.belongsTo('algorithm', { inverse: null }),
  // deviceBuild: DS.belongsTo('deviceBuild', { inverse: null }),
});
