import { Factory } from 'ember-cli-mirage';

export default Factory.extend({
  username: "",
  email: "",
  avatarUrl: "",
  authorized: false,
  confirmed: false,
  providers: [],
  errors: null,
  avatar: null,
  info: "",
  url: "",
  location: ""
});
