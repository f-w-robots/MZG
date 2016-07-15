import Ember from 'ember';

export default Ember.Controller.extend({
  devicesController: Ember.inject.controller('devices'),
  dm: Ember.inject.service('devices-manager'),
  output: null,
  //
  // algorithmObserver: function() {
  //   var target = null;
  //   this.get('algorithms').find(function(i){
  //     if(this.get('model.algorithmId') === i.get('id')) {
  //       target = i;
  //     }
  //   }, this);
  //   this.set('algorithm', target);
  // }.observes('model.algorithmId'),

  modelObserver: function() {
    this.set('output', this.get('dm.output.' + this.get('model.hwid')));
  }.observes('model'),

  setup: function() {
    this.set('devicesController.currentDeviceId', this.get('model.id'));
    this.get('dm').addObserver('outputUpdated', function() {
      this.set('output', this.get('dm.output.' + this.get('model.hwid')));
    }.bind(this));
  }.on('init'),

  pushErrors: function(errors) {
    $.each(Object.keys(errors), function(i, key){
      this.get('errors').push(key + ' ' + errors[key].join(','));
    }.bind(this));
    this.notifyPropertyChange('errors');
  },

  actions: {
    update: function() {
      this.set('errors', []);
      $.each([this.get('algorithm')], function(i, model) {
        if(model) {
          model.save().then(function(model) {
            this.pushErrors(model.get('errors'));
            if(this.get('errors').length === 0) {
              this.set('saveSuccess', 'success');
            }
          }.bind(this), function() {
            this.pushErrors(['undefined Error']);
          }.bind(this));
        }
      }.bind(this));

      this.get('model').save().then(function(model) {
        this.pushErrors(model.get('errors'));
        if(this.get('errors').length === 0) {
          this.set('saveSuccess', 'success');
        }
        this.get('dm').updateDevice(this.get('model.hwid'));
        this.set('dm.output.' + this.get('model.hwid'), []);
        this.set('output', null);
      }.bind(this), function(model) {
        this.pushErrors({'': [model.errors[0].detail]});
      }.bind(this));

      setTimeout(function(){
        this.set('saveSuccess', null);
      }.bind(this), 1500);
    },

    apply: function(code) {
      this.set('badCode', false);
      code = code.replace(/(")/g,'\\"');
      code = code.replace(/(?:\r\n|\r|\n)/g, '\\n');
      this.get('dm').updateCode(this.get('model.hwid'), code);
    },

    delete: function(device) {
      device.deleteRecord();
      device.save();
      this.transitionToRoute('/devices');
    },

    addModule: function() {
      var record = this.store.createRecord('component', {name: 'new name'})
      record.save().then(function(component) {
        var build = this.get('model.build.content');
        console.log(build);
        build.get('components').pushObject(record);
        build.save();
      }.bind(this));
    }
  },
});
