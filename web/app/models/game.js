import DS from 'ember-data';

export default DS.Model.extend({
  timeoutM: DS.attr('number'),
  timeoutS: DS.attr('number'),
  rounds: DS.attr('number'),
});
