import Ember from 'ember';

import saveModelControllerMixin from '../mixins/save-model-controller';

export default Ember.Component.extend(saveModelControllerMixin, {
  algorithmInterfaceObserver: function() {
    this.set('badCode', null);
    if(!this.get('model.manual')) {
      var target = null;
      var algorithmId = this.get('model.algorithmId');

      this.get('algorithms').find(function(i){
        if(algorithmId == i.get('algorithmId'))
          target = i;
      });
      this.set('algorithm', target)
      this.set('interface', null)
    } else {
      var target = null;
      var interfaceId = this.get('model.interfaceId');
      this.get('interfaces').find(function(i){
        if(interfaceId == i.get('interfaceId'))
          target = i;
      });
      console.log(target);
      this.set('interface', target)
      this.set('algorithm', null)
    }
  }.observes('model', 'model.manual','model.algorithmId', 'model.interfaceId'),

  setup: function() {
    Ember.DMSocket.addOnMessage('bad_code', function(data) {
      if(this.get('_state') == 'inDOM') {
        this.set('badCode', true);
      }
    }, this);
    this.algorithmInterfaceObserver();
  }.on('init'),

  actions: {
    editInterface: function() {
      var interfaceId = this.get('model.interfaceId');
      var interfac;
      this.get('interfaces').find(function(i){
        if(interfaceId == i.get('interfaceId'))
          interfac = i;
      });
      this.set('interface', interfac)
      this.set('algorithm', null);
    },

    editAlgorithm: function() {
      var interfaceId = this.get('model.algorithmId');
      var target;
      this.get('algorithms').find(function(i){
        if(interfaceId == i.get('algorithmId'))
          target = i;
      });
      this.set('algorithm', target)
      this.set('interface', null);
    },

    saveRecord: function() {
      var self = this;

      var models = [this.get('model')];
      if(this.get('interface'))
        models.push(this.get('interface'));
      if(this.get('algorithm'))
        models.push(this.get('algorithm'));
      $.each(models, function(i, model) {
        model.save().then(function() {
          self.set('saveStatus', 'success');
        }, function(){
          self.set('saveStatus', 'error');
        });
      })

      setTimeout(function(){
        self.set('saveStatus', null);
      }, 1500);
    },

    apply: function(code) {
      this.set('badCode', false);
      if(!String.prototype.replaceAll) {
        String.prototype.replaceAll = function(search, replacement) {
          var target = this;
          return target.replace(new RegExp(search, 'g'), replacement);
        };
      }
      code = code.replaceAll('"','\\"')
      code = code.replace(/(?:\r\n|\r|\n)/g, '\\n');
      Ember.DMSocket.sendDirect("{\"restart\":\"" + this.get('model.hwid') + "\",\"code\":\"" + code + "\"}")
    },
  },
});
