//$(document).delegate '*[data-toggle="lightbox"]', 'click', (event) ->
//  event.preventDefault()
//  $(this).ekkoLightbox()
//  return

!function ($) {
  $(function () {

    // delegate calls to data-toggle="lightbox"
    $(document).delegate('*[data-toggle="lightbox"]', 'click', function(event) {
      event.preventDefault();
      return $(this).ekkoLightbox({
        always_show_close: false,
        onShown: function() {
          var lb = this;
          $(lb.modal_content).addClass('zoom-out');
          $(lb.modal_content).click(function(e) {
            e.preventDefault();
            lb.close();
          });
        }
      });
    });

  });

}(window.jQuery);