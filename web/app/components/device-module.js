import Ember from 'ember';

export default Ember.Component.extend({
  store: Ember.inject.service('store'),

  classNames: ['device-module'],
  shelfModulesOptions: [],

  modules: [],

  setup: function() {
    this.get('store').findAll('shelfModule').then(function(modules) {
      this.set('shelfModulesOptions', modules.map(function(module){
        return {
          value: module.get('id'),
          label: module.get('name'),
        }
      }));
    }.bind(this));
  }.on('init'),

  actions: {
    addMod: function() {
      var mod = this.get('store').peekRecord('shelfModule', this.get('selectedModule'));
      this.get('modules').push({
        name: mod.get('name'),
        pins: mod.get('pins'),
      })
      this.notifyPropertyChange('modules');
    }
  }
});
