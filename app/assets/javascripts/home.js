// http://stackoverflow.com/questions/4459379/preview-an-image-before-it-is-uploaded

!function ($) {
  $(function () {

    $("#upload").change(function (){
      $('#files').html('');
      var files = $(this).prop('files');
      var imageType = /image.*/;
      for (var i=0; i < files.length; i++) {
        var file = files[i];
        if (!file.type.match(imageType)) {
          continue;
        }
        var reader = new FileReader();
        var img = $('<img class="img_preview" width="200" alt="Preview">');
        var img_info = $('<p class="file_name">' + file.name + ' (' + file.size + ' bytes)</p>');
        var img_div = $('<div class="img_file"></div>');
        img_div.append(img);
        img_div.append(img_info);

        $('#files').append(img_div);
        reader.onload = (function(aImg){
          return function(e) {
            aImg.attr('src', e.target.result);
          }
        })(img);
        reader.readAsDataURL(file);
      }

    });

  });
}(jQuery);