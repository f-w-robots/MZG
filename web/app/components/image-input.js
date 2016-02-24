export default Ember.Component.extend({
  file: null,

  actions: {
    fileSelectionChanged: function(file) {
      this.set('file', file);
    },

    removeImage: function(file) {
      this.$('input[type="file"]').val('');
      this.set('file', file);
    },
  },
});
