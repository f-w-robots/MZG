import Model from 'ember-data/model';

export default Model.extend({
    authorized: DS.attr('boolean'),
    username: DS.attr('string'),
    password: DS.attr('string'),
    passwordConfirmation: DS.attr('string'),
    errors: DS.attr('array'),
});
