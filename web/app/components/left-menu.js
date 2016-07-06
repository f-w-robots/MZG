import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'ul',
  classNames: ['nav', 'navbar-nav', 'navbar-right'],

  didInsertElement: function() {
    var toggler = '.navbar-toggle';
    var pagewrapper = 'section';
    var slidewidth = '160px';
    var menuneg = '-100%';
    var slideneg = '-160px';

    $("#slide-nav").on("click", toggler, function (e) {

        var selected = $(this).hasClass('slide-active');

        var scrollPosition;

        if(!selected) {
          scrollPosition = [
            window.self.pageXOffset || document.documentElement.scrollLeft || document.body.scrollLeft,
            window.self.pageYOffset || document.documentElement.scrollTop  || document.body.scrollTop
          ];
          $('body').data('scroll-position', scrollPosition);
          $('body').css('overflow', 'hidden');
          window.scrollTo(scrollPosition[0], scrollPosition[1]);
        } else {
          scrollPosition = $('body').data('scroll-position');
          $('body').css('overflow', 'inherit');
          window.scrollTo(scrollPosition[0], scrollPosition[1]);
        }

        $('#slidemenu').stop().animate({
            right: selected ? menuneg : '0px'
        });

        $('.navbar-height-col').stop().animate({
            right: selected ? slideneg : '0px'
        });

        $(pagewrapper).stop().animate({
            right: selected ? '0px' : slidewidth
        });

        $(this).toggleClass('slide-active', !selected);
        $('#slidemenu').toggleClass('slide-active');

        $(pagewrapper + ' .navbar, body, .navbar-header').toggleClass('slide-active');
    });

    var selected = pagewrapper + '#slidemenu, body, .navbar, .navbar-header';

    $(window).on("resize", function () {
        if ($(window).width() > 767 && $('.navbar-toggle').is(':hidden')) {
            $(selected).removeClass('slide-active');
        }
    });

  },

  actions: {
    logout: function() {
      location.replace("http://" + location.hostname + ":2600/auth/logout");
    }
  }
});
