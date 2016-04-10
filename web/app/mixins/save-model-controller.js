import Ember from 'ember';

export default Ember.Mixin.create({
  setup() {
    this.set('saveStatus', null);
  },

  saveSuccess: function() {
    return this.get('saveStatus') === 'success'
  }.property('saveStatus'),

  saveError: function() {
    return this.get('saveStatus') === 'error'
  }.property('saveStatus'),

  actions: {
    saveRecord: function() {
      var self = this;
      this.get('model').save().then(function() {
        self.set('saveStatus', 'success');
      }, function(){
        self.set('saveStatus', 'error');
      });
    },
  }
});
