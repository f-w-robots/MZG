import Ember from 'ember';

export default Ember.Component.extend({
  optionsObserver: function () {
    this.set('fieldValue', this.get('model.options.'+this.get('field')));
  }.observes('model.options'),

  optionsUpdate: function() {
    this.optionsObserver();
  }.on('init'),

  fieldValueObserver: function() {
    this.set('model.options.'+this.get('field'), this.get('fieldValue'));
  }.observes('fieldValue'),

});
