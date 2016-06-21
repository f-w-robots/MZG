import DS from 'ember-data';

export default DS.Model.extend({
    authorized: DS.attr('boolean'),
    username: DS.attr('string'),
    avatarUrl: DS.attr('string'),
    email: DS.attr('string'),
    password: DS.attr('string'),
    passwordConfirmation: DS.attr('string'),
    providers: DS.attr('array'),
    errors: DS.attr('array'),
    avatar: DS.attr(),
});
