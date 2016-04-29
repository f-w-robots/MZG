import Ember from 'ember';

import saveModelControllerMixin from '../mixins/save-model-controller';

export default Ember.Component.extend(saveModelControllerMixin, {
  dm: Ember.getDMSocket(),
  output: null,

  algorithmObserver: function() {
    var target = null;
    this.get('algorithms').find(function(i){
      if(this.get('model.algorithmId') == i.get('id')) {
        target = i;
      }
    }, this);
    this.set('algorithm', target)
  }.observes('model.algorithmId'),

  modelObserver: function() {
    this.set('output', this.get('dm.output.' + this.get('model.hwid')))
  }.observes('model'),

  setup: function() {
    var self = this;
    this.algorithmObserver();
    this.get('dm').addObserver('outputUpdated', function() {
      self.set('output', self.get('dm.output.' + self.get('model.hwid')))
    });
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
