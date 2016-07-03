import Ember from 'ember';

export default Ember.Mixin.create({
  setup() {
    this.set('saveStatus', null);
  },

  saveSuccess: function() {
    return this.get('saveStatus') === 'success';
  }.property('saveStatus'),

  saveError: function() {
    return this.get('saveStatus') === 'error';
  }.property('saveStatus'),

  actions: {
    saveRecord: function() {
      var model = this.get('model');
      model.save().then(function() {
        this.set('saveStatus', 'success');
      }.bind(this), function(){
        this.set('saveStatus', 'error');
      }.bind(this));
    },
  }
});
