import Ember from 'ember';

export default Ember.Component.extend({
  value: null,

  optionsObserver: function () {
    if(!this.get('options')) {
      return [];
    }
    return this.set('optionsList', this.get('options').map(function(e){
      return {
        value: e.get(this.get('valueKey')),
        label: e.get(this.get('labelKey')),
        selected: e.get(this.get('valueKey')) === this.get('value'),
      };
    }.bind(this)));
  }.observes('options.length'),

  optionsUpdate: function() {
    this.optionsObserver();
  }.on('init'),

  actions: {
    select: function(e) {
      this.set('value', e.target.value);
    }
  }
});
