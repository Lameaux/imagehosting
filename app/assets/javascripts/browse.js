!function ($) {
  $(function () {

    $('.show-more').click(function(){
      var url = $(this).data('url');
      var offset = $(this).data('offset');
      var that = this;
      $.get(url + '?offset=' + offset + '&ajax=true', function (data) {
        $('.browse-list').append(data.body);
        $(that).data('offset', data.offset);
        if (!data.show_more) {
          $(that).addClass('hidden');
        }
      });
      return false;
    });

  });

}(window.jQuery);