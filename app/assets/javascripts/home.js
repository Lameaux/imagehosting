// http://stackoverflow.com/questions/4459379/preview-an-image-before-it-is-uploaded

var upload_files = [];
var upload_results = [];

!function ($) {
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
    });

    $("#upload_button").click(function(){

      $('.thumb_detail').addClass('hidden');
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
}(jQuery);

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
  if (upload_files.length > 0) {
    $('.upload_button_well').removeClass('hidden');
  } else {
    $('.upload_button_well').addClass('hidden');
  }
  printTemplates();
}

function removePreviewThumbnail() {
  var id = $(this).data('id');
  upload_files.splice(id,1);
  if (upload_files.length == 0) {
    $('.upload_button_well').addClass('hidden');
  }
  printTemplates();
}

function removeUploadedThumbnail() {
  var id = $(this).data('id');
  alert(id);
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

  var thumbnail_html = '' +
      '<div class="col-md-4 col-sm-6 col-xs-12" id="preview_' + index + '">' +
        '<div class="thumbnail">' +
          '<img class="thumb_cover" alt="' + file.name + '" title="' + file.name + ' (' + file.size + ' bytes)" src="/img/1px.gif">' +
        '</div>' +
        '<div class="thumb_detail">' +
          '<div class="input-group ">' +
            '<span class="input-group-btn">' +
              '<button class="btn btn-default preview-remove" type="button" title="Remove" data-id="' + index + '">' +
                '<span class="glyphicon glyphicon-trash"></span>' +
              '</button> ' +
            '</span>' +
            '<input type="text" id="file_name_' + index + '" class="form-control" aria-label="Link" value="' + file.name + '">' +
          '</div>' +
        '</div>' +
        '<p class="thumb_status hidden">Pending...</p>' +
      '</div>';
  var thumbnail = $(thumbnail_html);
  thumbnail.find('.preview-remove').click(removePreviewThumbnail);

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
  formData.append('file_name', $('#file_name_' + id).val());

  $.ajax({
    url : '/upload',
    type : 'POST',
    data : formData,
    processData: false,
    contentType: false,
    success : function(data) {

      upload_results[id] = data;

      var success_html = '' +
      '<div class="input-group thumb_status_margin">' +
          '<input type="text" class="form-control" aria-label="Link" value="' + data.file_name + '">' +
          '<span class="input-group-btn">' +
            '<button class="btn btn-default" type="button"><span class="glyphicon glyphicon-pencil"></span></button>' +
          '</span>' +
      '</div>' +
      '<div class="input-group thumb_status_margin">' +
          '<span class="input-group-addon">Link</span>' +
          '<input type="text" class="form-control image-url" aria-label="Link" value="' + data.url + '" readonly>' +
      '</div>' +
      '<div>' +
          '<button class="btn btn-default clipboard-btn" type="button" title="Copy to Clipboard">' +
          '<span class="glyphicon glyphicon-copy"></span> Copy link' +
          '</button> ' +
          '<button class="btn btn-default" type="button"><span class="glyphicon glyphicon-link"></span> Embed code</button> ' +
          '<button class="btn btn-default" type="button"><span class="glyphicon glyphicon-trash"></span> Delete</button>' +
      '</div>' +
      '';

      var success = $(success_html);

      success.find('.image-url').click(selectText);
      success.find('.clipboard-btn').click(copyToClipboard);

      $('#preview_' + id).find('.thumb_status').html(success);
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
  processFiles(files);
}