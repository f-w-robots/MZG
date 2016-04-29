import Ember from 'ember';

export default Ember.Component.extend({
  didRender: function() {
    var elem = this.$('.std-output')[0];
    elem.scrollTop = elem.scrollHeight;
  }
});
