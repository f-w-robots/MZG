import Ember from 'ember';

export default Ember.Component.extend({
  didInsertElement: function() {
    this.set('editor', window.ace.edit('editor'));
    this.editor.getSession().setTabSize(2);
    // this.get('editor').setTheme("ace/theme/monokai");
    this.editor.getSession().setMode("ace/mode/" + this.get('mode'));

    this.get('editor').getSession().setValue(this.get('value'));
    this.get('editor').on('change', function(){
      this.set('value', this.get('editor').getSession().getValue());
    }.bind(this));
  },

  valueChanged: function () {
    if (!this.get('value'))
      this.get('editor').getSession().setValue('');
    else if (this.get('editor').getSession().getValue() !== this.get('value'))
      this.get('editor').getSession().setValue(this.get('value'));
  }.observes('value')
});
