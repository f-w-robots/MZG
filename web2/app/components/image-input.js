export default Ember.Component.extend({
  file: null,
  actions: {
    fileSelectionChanged: function(file) {
      this.set('file', file)
    },
  },
});
