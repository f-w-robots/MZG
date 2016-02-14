import Ember from 'ember';

export default Ember.Route.extend({
  controllerName: 'interfaces',

  model() {
    return {id: ''};
  },

  renderTemplate() {
    this.render('interface.edit');
  },
});
