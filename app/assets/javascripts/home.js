// http://stackoverflow.com/questions/4459379/preview-an-image-before-it-is-uploaded

var upload_files = [];

!function ($) {
  $(function () {

    $("#upload_files").change(function (){
      var files = $(this).prop('files');
      var imageType = /image.*/;
      var index= 0;
      for (var i=0; i < files.length; i++) {
        var file = files[i];
        if (!file.type.match(imageType)) {
          continue;
        }
        upload_files.push(file);
      }
      if (upload_files.length > 0) {
        $('button#upload_button').removeClass('hidden');
      } else {
        $('button#upload_button').addClass('hidden');
      }
      printTemplates();
    });
  });
}(jQuery);

var removeThumbnail = function() {
  var id = $(this).data('id');
  upload_files.splice(id,1);
  $('#preview_' + id).remove();
  if (upload_files.length == 0) {
    $('button#upload_button').addClass('hidden');
  }
};

function createThumbnail(file, index) {

  var thumbnail_html = '<div class="col-md-3 col-sm-4 col-xs-6" id="preview_' + index + '">' +
      '<div class="thumbnail">' +
      '<img class="thumb_cover" alt="' + file.name + '" title="' + file.name + ' (' + file.size + ' bytes)" src="/img/1px.gif">' +
      '</div>' +
      '<p class="thumb_detail">' +
      '<button class="btn btn-default btn-xs preview-remove" title="Remove" data-id="' + index + '"><span class="glyphicon glyphicon-remove"></span></button> ' + file.name +
      '</p>' +
      '</div>';
  var thumbnail = $(thumbnail_html);
  thumbnail.find('.preview-remove').click(removeThumbnail);

  var reader = new FileReader();
  reader.onload = (function(aImg){
    return function(e) {
      aImg.css('background-image', "url('" + e.target.result + "')");
    }
  })(thumbnail.find('img.thumb_cover'));
  reader.readAsDataURL(file);

  return thumbnail;
}

function printTemplates() {
  $('#preview_files').html('');
  for (var i=0; i < upload_files.length; i++) {
    var file = upload_files[i];
    $('#preview_files').append(createThumbnail(file, i));
  }
}