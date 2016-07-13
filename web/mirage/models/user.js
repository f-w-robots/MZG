import { Model } from 'ember-cli-mirage';

export default Model.extend({
  "username": "",
  "email": "",
  "avatar-url": "",
  "authorized": false,
  "confirmed": false,
  "providers": [],
  "errors": null,
  "avatar": null,
  "info": "",
  "url": "",
  "location": ""
});
