export default Ember.TextField.extend({
  type: 'file',
  // classNames: [''],

  change: function(e) {

    var inputFiles = e.target.files;
    if (inputFiles.length < 1) {
      return;
    }

    let inputFile = inputFiles[0];

    let fileInfo = {
      name: inputFile.name,
      type: inputFile.type || 'n/a',
      size: inputFile.size,
      date: inputFile.lastModifiedDate ?
        inputFile.lastModifiedDate.toLocaleDateString() : 'n/a',
    };

    var fileReader = new FileReader();

    fileReader.onload = function(e) {
      let fileReader = e.target;
      fileInfo.dataURL = fileReader.result;

      this.sendAction('fileChanged', fileInfo);
    }.bind(this);

    let firstFile = e.target.files[0];
    fileReader.readAsDataURL(firstFile);
  },
});
