var FILE_SIZE_LIMIT = 500 * 1024;
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


    $('#paste_url_button').click(function(){
      var url = $('#paste_url').val();
      if (!isURL(url)) {
        alert('Invalid URL: ' + url);
        return;
      }
      $('#paste_url').val('');

      upload_files.push(url);
      if (upload_files.length > 0) {
        $('.upload_button_well').removeClass('hidden');
      } else {
        $('.upload_button_well').addClass('hidden');
      }
      printTemplates();

    });

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
    if (file.size > FILE_SIZE_LIMIT) {
      alert('File ' + file.name + ' is too big (' + file.size + ' bytes).');
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

function editImage() {

  var id = $(this).data('id');
  var index = $(this).data('index');

  $.ajax({
    url: '/' + id,
    type: 'PUT',
    processData: false,
    contentType: false,
    success: function (data) {

    }
  });

}

function deleteImage() {

  var id = $(this).data('id');
  var index = $(this).data('index');

  $.ajax({
    url: '/' + id,
    type: 'DELETE',
    processData: false,
    contentType: false,
    success: function (data) {
      $('#preview_' + index).remove();
    }
  });

}

function createThumbnail(file, index) {

  if (file instanceof File) {
    file_name = file.name;
  } else {
    file_name = file;
  }

  var thumbnail_html = '' +
      '<div class="col-md-4 col-sm-6 col-xs-12 preview" id="preview_' + index + '">' +
        '<div class="thumbnail">' +
          '<img class="thumb_cover" alt="' + file_name + '" title="' + file_name + '" src="/img/1px.gif">' +
        '</div>' +
        '<div class="thumb_detail">' +
          '<div class="input-group ">' +
            '<span class="input-group-btn">' +
              '<button class="btn btn-default preview-remove" type="button" title="Remove" data-id="' + index + '">' +
                '<span class="glyphicon glyphicon-trash"></span>' +
              '</button> ' +
            '</span>' +
            '<input type="text" id="file_name_' + index + '" class="form-control" aria-label="Link" value="' + file_name + '">' +
          '</div>' +
        '</div>' +
        '<p class="thumb_status hidden">Pending...</p>' +
      '</div>';
  var thumbnail = $(thumbnail_html);
  thumbnail.find('.preview-remove').click(removePreviewThumbnail);

  if (file instanceof File) {
    var reader = new FileReader();
    reader.onload = (function (aImg) {
      return function (e) {
        aImg.css('background-image', "url('" + e.target.result + "')");
      }
    })(thumbnail.find('img.thumb_cover'));
    reader.readAsDataURL(file);
  } else {
    thumbnail.find('img.thumb_cover').css('background-image', "url('" + file + "')")
  }

  return thumbnail;
}

function printTemplates() {
  $('.preview').remove();
  for (var i=0; i < upload_files.length; i++) {
    var file = upload_files[i];
    $('#drop_zone').after(createThumbnail(file, i));
  }
}

function uploadFile(id) {

  $('#preview_' + id).find('.thumb_status').html('Uploading...');

  var formData = new FormData();

  if (upload_files[id] instanceof File) {
    formData.append('file', upload_files[id]);
  } else {
    formData.append('file_url', upload_files[id]);
  }

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
          '<input type="text" class="form-control" id="image_title_' + id + '" aria-label="Image title" value="' + data.file_name + '">' +
          '<span class="input-group-btn">' +
            '<button class="btn btn-default edit-btn" type="button" data-id="' + data.id + '" data-index="' + id + '"><span class="glyphicon glyphicon-pencil"></span></button>' +
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
          '<button class="btn btn-default" type="button" data-toggle="modal" data-target="#embed_code_' + data.id + '"><span class="glyphicon glyphicon-link"></span> Embed code</button> ' +
          '<button class="btn btn-default delete-btn" type="button" data-id="' + data.id + '" data-index="' + id + '"><span class="glyphicon glyphicon-trash"></span> Delete</button>' +
      '</div>' +
      '<div class="modal fade" id="embed_code_' + data.id + '" role="dialog">' +
          '<div class="modal-dialog modal-lg">' +
          '<div class="modal-content">' +
          '<div class="modal-header">' +
          '<button type="button" class="close" data-dismiss="modal">&times;</button>' +
          '<h4 class="modal-title">Embed code</h4>' +
          '</div>' +
          '<div class="modal-body">' +
          '<pre><code>' +
          $("<div>").text('<a target="_blank" href="' + data.url + '" title="' + data.file_name + '">' + "\r\n\t" + '<img src="' + data.thumb_url + '" alt="' + data.file_name + '">' + "\r\n" + '</a>').html() +
          '</code></pre>' +
          '</div>' +
          '<div class="modal-footer">' +
          '<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>' +
          '</div>' +
          '</div>' +
          '</div>' +
      '</div>' +
      '';

      var success = $(success_html);

      success.find('.image-url').click(selectText);
      success.find('.clipboard-btn').click(copyToClipboard);
      success.find('.edit-btn').click(editImage);
      success.find('.delete-btn').click(deleteImage);


      $('#preview_' + id).find('.thumb_status').html(success);
      continueUploading();
    },
    error: function() {
      upload_results[id] = 'failed';

      var error_html = '<div>Upload Failed... <button type="button" class="btn btn-default try-again hidden">Try again</button></div>';
      var error = $(error_html);
      error.find('.try-again').click(function(){
        upload_results[id] = false;
        continueUploading();
      });

      $('#preview_' + id).find('.thumb_status').html(error);
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
  $('.try-again').removeClass('hidden');
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

function isURL(str) {
  var pattern = new RegExp('^(https?:\\/\\/)?'+ // protocol
      '((([a-z\\d]([a-z\\d-]*[a-z\\d])*)\\.?)+[a-z]{2,}|'+ // domain name
      '((\\d{1,3}\\.){3}\\d{1,3}))'+ // OR ip (v4) address
      '(\\:\\d+)?(\\/[-a-z\\d%_.~+]*)*'+ // port and path
      '(\\?[;&a-z\\d%_.~+=-]*)?'+ // query string
      '(\\#[-a-z\\d_]*)?$','i'); // fragment locator
  return pattern.test(str);
}