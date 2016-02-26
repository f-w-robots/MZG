import Ember from 'ember';

export default Ember.Route.extend({
  controllerName: 'admin',

  model() {
    var self = this;
    return this.store.findAll('group').then(function(games) {
      if(games.get('firstObject')) {
        return games.get('firstObject');
      } else {
        return self.store.createRecord('group', {timeoutM: 1, timeoutS: 30, rounds: 5});
      }
    });
  },
});
