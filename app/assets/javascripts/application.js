// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require bootstrap-sprockets
//= require lightbox-bootstrap
//= require jquery_ujs
//= require_tree .

!function ($) {
  $(function(){

    $('#back-top').fadeOut();
    $(document).scroll(function () {
      var y = $(this).scrollTop();
      if (y > 300) {
        $('#back-top').fadeIn();
      } else {
        $('#back-top').fadeOut();
      }
    });
    $('#back-top').click(function () {
      $('html, body').animate({scrollTop: 0}, 800);
      return false;
    });

  });

}(window.jQuery);