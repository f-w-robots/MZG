import Model from 'ember-data/model';
// import attr from 'ember-data/attr';
// import { belongsTo, hasMany } from 'ember-data/relationships';

export default Model.extend({
  name: DS.attr('string'),
  key: DS.attr('string'),
  pins: DS.attr('array'),
});
