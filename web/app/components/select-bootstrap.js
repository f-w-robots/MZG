import Ember from 'ember';

export default Ember.Component.extend({
  value: null,

  optionsObserver: function () {
    var self = this;
    return this.set('optionsList', this.get('options').map(function(e){
      return {
        value: e.get(self.get('valueKey')),
        label: e.get(self.get('labelKey')),
        selected: e.get(self.get('valueKey')) == self.get('value'),
      };
    }));
  }.observes('options.length'),

  optionsUpdate: function() {
    this.optionsObserver()
  }.on('init'),

  actions: {
    select: function(e) {
      this.set('value', e.target.value);
    }
  }
});
