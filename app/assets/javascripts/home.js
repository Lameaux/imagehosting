// http://stackoverflow.com/questions/4459379/preview-an-image-before-it-is-uploaded

var upload_files = [];
var upload_results = [];

//!function ($) {
  $(function () {

    // Check for the various File API support.
    if (window.File && window.FileReader && window.FileList && window.Blob) {
      // Great success! All the File APIs are supported.
    } else {
      alert('The File APIs are not fully supported in this browser.');
    }


    $("#upload_files").change(function (){
      var files = $(this).prop('files');
      processFiles(files);
      if (upload_files.length > 0) {
        $('button#upload_button').removeClass('hidden');
      } else {
        $('button#upload_button').addClass('hidden');
      }
      printTemplates();
    });

    $("#upload_button").click(function(){
      $('.preview-remove').addClass('hidden');
      $('.thumb_status').removeClass('hidden');

      $("#upload_files_label").addClass('hidden');
      $(this).addClass('hidden');
      $('#drop_zone').addClass('hidden');

      for (var i = 0; i < upload_files.length; i++) {
        upload_results[i] = false;
      }
      continueUploading();
      return false;
    });


    $('body').on('dragover', '#drop_zone', handleDragOver);
    $('body').on('drop', '#drop_zone', handleDrop);

  });
//}(jQuery);

function processFiles(files) {
  var imageType = /image.*/;
  var index= 0;
  for (var i=0; i < files.length; i++) {
    var file = files[i];
    if (!file.type.match(imageType)) {
      continue;
    }
    upload_files.push(file);
  }
}

function removeThumbnail() {
  var id = $(this).data('id');
  upload_files.splice(id,1);
  if (upload_files.length == 0) {
    $('button#upload_button').addClass('hidden');
  }
  printTemplates();
}

function selectText() {
  this.setSelectionRange(0, this.value.length);
}

function copyToClipboard() {
  var image_url = ($(this).parents('.thumb_status').find('.image-url'))[0];
  image_url.setSelectionRange(0, image_url.value.length);
  document.execCommand("copy");
}

function createThumbnail(file, index) {

  var thumbnail_html = '<div class="col-md-3 col-sm-4 col-xs-6" id="preview_' + index + '">' +
      '<div class="thumbnail">' +
      '<img class="thumb_cover" alt="' + file.name + '" title="' + file.name + ' (' + file.size + ' bytes)" src="/img/1px.gif">' +
      '</div>' +
      '<p class="thumb_detail">' +
      '<button class="btn btn-default btn-xs preview-remove" title="Remove" data-id="' + index + '"><span class="glyphicon glyphicon-trash"></span></button> ' + file.name +
      '</p>' +
      '<p class="thumb_status hidden">Pending...</p>' +
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

function uploadFile(id) {

  $('#preview_' + id).find('.thumb_status').html('Uploading...');

  var formData = new FormData();
  formData.append('file', upload_files[id]);

  $.ajax({
    url : '/upload',
    type : 'POST',
    data : formData,
    processData: false,  // tell jQuery not to process the data
    contentType: false,  // tell jQuery not to set contentType
    success : function(data) {

      upload_results[id] = data;

      var success_html = $('<div class="input-group">' +
      '<span class="input-group-addon">Link</span>' +
      '<input type="text" class="form-control image-url" aria-label="Link" value="' + data.url + '" readonly>' +
      '<span class="input-group-btn">' +
          '<button class="btn btn-default clipboard-btn" title="Copy to Clipboard">' +
            '<span class="glyphicon glyphicon-copy"></span>' +
          '</button>' +
      '</span>' +
      '</div>');

      success_html.find('.image-url').click(selectText);
      success_html.find('.clipboard-btn').click(copyToClipboard);

      $('#preview_' + id).find('.thumb_status').html(success_html);
      continueUploading();
    },
    error: function() {
      upload_results[id] = 'failed';
      $('#preview_' + id).find('.thumb_status').html('Failed... Try again');
      continueUploading();
    }

  });

}

function continueUploading() {
  for (var i = 0; i < upload_results.length; i++) {
    if (upload_results[i] == false) {
      return uploadFile(i);
    }
  }
  $('#new_upload_button').removeClass('hidden');
}


function handleDragOver(evt) {
  evt.stopPropagation();
  evt.preventDefault();
  evt.originalEvent.dataTransfer.dropEffect = 'copy'; // Explicitly show this is a copy.
}

function handleDrop(evt) {
  evt.stopPropagation();
  evt.preventDefault();
  var files = evt.originalEvent.dataTransfer.files;
  console.log(files);
}