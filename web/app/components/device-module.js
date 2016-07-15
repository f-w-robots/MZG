import Ember from 'ember';

export default Ember.Component.extend({
  store: Ember.inject.service('store'),

  classNames: ['device-module'],
  shelfModulesOptions: [],
  // component: null,

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
      if(!this.get('module.mods')) {
        this.set('module.mods', []);
      }
      var pins = [];
      $.each(mod.get('pins'), function(index, pin) {
        pins.push({
          type: pin,
          value: '',
        })
      });
      this.get('module.mods').pushObject({
        name: mod.get('name'),
        pins: pins,
      });
      this.get('module').save();
    },

    save() {
      this.notifyPropertyChange('module.mods');
      this.get('module').save();
    },
  }
});
