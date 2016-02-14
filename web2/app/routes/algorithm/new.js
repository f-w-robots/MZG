import Ember from 'ember';

export default Ember.Route.extend({
  controllerName: 'algorithms',

  model() {
    return {};
  },

  renderTemplate() {
    this.render('algorithm.edit');
  },
});
