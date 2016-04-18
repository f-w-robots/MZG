import Ember from 'ember';

import saveModelControllerMixin from '../mixins/save-model-controller';

export default Ember.Component.extend(saveModelControllerMixin, {
  deviceObserver: function() {
    this.set('algorithm', null)
    this.set('interface', null);
  }.observes('model', 'model.manual'),

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
  },
});
