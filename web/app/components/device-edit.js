import Ember from 'ember';

import saveModelControllerMixin from '../mixins/save-model-controller';

export default Ember.Component.extend(saveModelControllerMixin, {
  dm: Ember.getDMSocket(),

  algorithmObserver: function() {
    var target = null;

    this.get('algorithms').find(function(i){
      console.log();
      if(this.get('model.algorithmId') == i.get('id')) {
        target = i;
      }
    }, this);
    this.set('algorithm', target)
    console.log(target);
  }.observes('model.algorithmId'),

  setup: function() {
    this.algorithmObserver();
    // this.interfaceObserver();
    this.set('output', Ember.computed.alias('dm.output.' + this.get('model.hwid')));
  }.on('init'),

  actions: {
    update: function() {
      var self = this;
      $.each([this.get('interface'), this.get('algorithm')], function(i, model) {
        if(model) {
          model.save().then(function() {
            self.set('saveStatus', 'success');
          }, function() {
            self.set('saveStatus', 'error');
          });
        }
      });

      this.get('model').save().then(function() {
          self.set('saveStatus', 'success');
          self.get('dm').updateDevice(self.get('model.hwid'));
          self.set('output', null)
        }, function() {
          self.set('saveStatus', 'error');
        });

      setTimeout(function(){
        self.set('saveStatus', null);
      }, 1500);
    },

    apply: function(code) {
      this.set('badCode', false);
      code = code.replace(/(")/g,'\\"');
      code = code.replace(/(?:\r\n|\r|\n)/g, '\\n');
      this.get('dm').updateCode(this.get('model.hwid'), code);
    },

    control: function(device) {
      if(this.get('controlUrl')) {
        this.set('controlUrl', undefined);
      } else {
        this.set('controlUrl', location.protocol + '//'
          + location.hostname + ':3900/' + device.get('hwid'));
      }
    },

    delete: function(device) {
      device.deleteRecord();
      device.save();
      this.set('model', null);
    },
  },
});
