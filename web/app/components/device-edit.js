import Ember from 'ember';

import saveModelControllerMixin from '../mixins/save-model-controller';

export default Ember.Component.extend(saveModelControllerMixin, {
  dm: Ember.getDMSocket(),

  algorithmObserver: function() {
    var target = null;

    this.get('algorithms').find(function(i){
      if(this.get('model.algorithmId') == i.get('algorithmId')) {
        target = i;
      }
    }, this);
    this.set('algorithm', target)
  }.observes('model.algorithmId'),

  interfaceObserver: function() {
    var target = null;

    this.get('interfaces').find(function(i){
      if(this.get('model.interfaceId') == i.get('interfaceId')) {
        target = i;
      }
    }, this);
    this.set('interface', target)
  }.observes('model.interfaceId'),

  setup: function() {
    this.algorithmObserver();
    this.interfaceObserver();
  }.on('init'),

  actions: {
    saveRecord: function() {
      var self = this;
      $.each([this.get('model'), this.get('interface'), this.get('algorithm')], function(i, model) {
        model.save().then(function() {
          self.set('saveStatus', 'success');
        }, function() {
          self.set('saveStatus', 'error');
        });
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

    kill: function(device) {
      this.get('dm').killDevice(device.get('hwid'));
    },

    control: function(device) {
      if(this.get('controlUrl')) {
        this.set('controlUrl', undefined);
      } else {
        this.set('controlUrl', location.protocol + '//'
          + location.hostname + ':3900/' + device.get('hwid'));
      }
    },
  },
});
