import Model from 'ember-data/model';

export default Model.extend({
    authorized: DS.attr('boolean'),
    username: DS.attr('string'),
    password: DS.attr('string'),
    passwordConfirmation: DS.attr('string'),
    providers: DS.attr('array'),
    errors: DS.attr('array'),
});
