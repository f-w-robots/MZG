import Ember from 'ember';

export default Ember.Component.extend({
  didInsertElement: function() {
    $('#slide-nav.navbar .container').append($('<div id="navbar-height-col"></div>'));

    // Enter your ids or classes
    var toggler = '.navbar-toggle';
    var pagewrapper = '#page-content';
    var navigationwrapper = '.navbar-header';
    var menuwidth = '100%'; // the menu inside the slide menu itself
    var slidewidth = '160px';
    var menuneg = '-100%';
    var slideneg = '-160px';

    $("#slide-nav").on("click", toggler, function (e) {


        var selected = $(this).hasClass('slide-active');
        if(selected) {
          $('body').css('position', 'inherit')
        } else {
          $('body').css('position', 'fixed')
        }
        //
        $('#slidemenu').stop().animate({
            right: selected ? menuneg : '0px'
        });

        $('#navbar-height-col').stop().animate({
            right: selected ? slideneg : '0px'
        });

        $(pagewrapper).stop().animate({
            right: selected ? '0px' : slidewidth
        });

        $(this).toggleClass('slide-active', !selected);
        $('#slidemenu').toggleClass('slide-active');

        $('#page-content, .navbar, body, .navbar-header').toggleClass('slide-active');
    });

    var selected = '#slidemenu, #page-content, body, .navbar, .navbar-header';

    $(window).on("resize", function () {
        if ($(window).width() > 767 && $('.navbar-toggle').is(':hidden')) {
            $(selected).removeClass('slide-active');
        }
    });

  },

  actions: {
    login: function() {
      location.replace("http://" + location.hostname + ":2600/auth/signin")
    },

    register: function() {
      location.replace("http://" + location.hostname + ":2600/auth/signup")
    },

    vkontakte: function() {
      location.replace("http://" + location.hostname + ":2600/auth/vkontakte")
    },

    githu: function() {
      location.replace("http://" + location.hostname + ":2600/auth/github")
    },

    logout: function() {
      location.replace("http://" + location.hostname + ":2600/auth/logout")
    }
  }
});
