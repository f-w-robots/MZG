import Ember from 'ember';
const { getOwner } = Ember

export default Ember.Component.extend({
    tagName: 'li',

    classNameBindings: ['isCurrentRoute:active'],

    currentRouteBinding: 'currentPath',

    currentRouteNameChanged: function() {
      this.updateState();
    }.observes('currentRouteName'),

    isCurrentRoute: function() {
      return this.updateState();
    }.property('isCurrentRoute'),

    updateState: function() {
      return this.set('isCurrentRoute', this.get('route') == this.get('currentRouteName'));
    },
});
