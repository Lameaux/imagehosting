!function ($) {
  $(function () {

    function showEditor(entityId, entityName, propertyName, tagName) {
      $(tagName + '.' + entityName + '-' + propertyName + '-' + entityId).removeClass('hidden');
      $(tagName + '.' + entityName + '-' + propertyName + '-' + entityId).focus();
      $('span.' + entityName + '-' + propertyName + '-' + entityId).addClass('hidden');
      $('button.' + entityName + '-' + propertyName + '-' + entityId).addClass('hidden');
    }

    function saveChanges(entityId, entityName, propertyName, propertyValue, tagName) {
      $('span.' + entityName + '-' + propertyName + '-' + entityId).removeClass('hidden');
      $('button.' + entityName + '-' + propertyName + '-' + entityId).removeClass('hidden');
      $(tagName + '.' + entityName + '-' + propertyName + '-' + entityId).addClass('hidden');

      var formData = new FormData();
      formData.append(propertyName, propertyValue);

      var updateUrl = '/' + entityId;
      if (entityName == 'album') {
        updateUrl = '/' + entityName + '/' + entityId;
      }

      $.ajax({
        url : updateUrl,
        type : 'PUT',
        data : formData,
        processData: false,
        contentType: false,
        success : function(data) {
          var escaped = $('<div>').text(data[propertyName]).html();
          $('span.' + entityName + '-' + propertyName + '-' + entityId).html(nl2br(escaped));
        }
      });
    }

    function triggerSaveChanges(that, entityName, propertyName, tagName) {
      var entityId = $(that).data(entityName + '-id');
      var propertyValue = $(that).val();
      saveChanges(entityId, entityName, propertyName, propertyValue, tagName);
    }

    [
      ['image', 'title', 'input'],
      ['image', 'description', 'textarea'],
      ['album', 'title', 'input'],
      ['album', 'description', 'textarea']
    ].forEach(function(element, index, array){
      var entityName = element[0];
      var propertyName = element[1];
      var tagName = element[2];
      $('button.edit-' + entityName + '-' + propertyName).click(function(){
        var entityId = $(this).data(entityName + '-id');
        showEditor(entityId, entityName, propertyName, tagName);
      });

      $(tagName + '.edit-' + entityName + '-' + propertyName).focusout(function(){
        triggerSaveChanges(this, entityName, propertyName, tagName);
      });

      if (tagName != 'textarea') {
        $(tagName + '.edit-' + entityName + '-' + propertyName).keypress(function(e) {
          if(e.which == 13) {
            e.preventDefault();
            this.blur();
          }
        });
      }
    });

    function triggerAddTag(that) {
      var imageId = $(that).data('image-id');
      $('button.add-image-tag-' + imageId).removeClass('hidden');
      $('input.add-image-tag-' + imageId).addClass('hidden');
      var tagValue = $('input.add-image-tag-' + imageId).val();
      if (tagValue == '') return;

      var formData = new FormData();
      formData.append('tag', tagValue);

      $.ajax({
        url: '/' + imageId + '/tags',
        type: 'POST',
        data : formData,
        processData: false,
        contentType: false,
        success: function (tagValue) {
          var tag_html = ' <span class="badge image-tag">' +
              '<span class="fa fa-hashtag" aria-hidden="true"></span>&nbsp;' +
              '<span class="image-tag-text">' + tagValue + '</span>&nbsp;' +
              '<span title="Remove" class="image-tag-remove image-tag-remove-' + imageId + ' fa fa-remove" data-image-id="' + imageId + '" data-tag-value="' + tagValue + '"></span>' +
              '</span> ';
          $('span.image-tags-' + imageId).append(tag_html);

          $('.image-tag-remove-' + imageId).click(function(){
            triggerRemoveTag(this);
          });
        }
      });

    }

    function triggerRemoveTag(that) {
      var imageId = $(that).data('image-id');
      var tagValue = $(that).data('tag-value');

      var formData = new FormData();
      formData.append('tag', tagValue);

      $.ajax({
        url: '/' + imageId + '/tags',
        type: 'PUT',
        data : formData,
        processData: false,
        contentType: false,
        success: function (data) {
          $(that).parent().remove();
        }
      });

    }

    $('button.add-image-tag').click(function(){
      showTagEditor(this);
    });

    $('.image-tag-remove').click(function(){
      triggerRemoveTag(this);
    });

    function showTagEditor(that){
      var imageId = $(that).data('image-id');
      var selector = 'add-image-tag-' + imageId;
      $('input.' + selector).val('');
      $('button.' + selector).addClass('hidden');
      $('input.' + selector).removeClass('hidden');
      $('input.' + selector).focus();
    }

    $('input.add-image-tag').focusout(function(){
      triggerAddTag(this)
    });

    $('input.add-image-tag').keypress(function(e) {
      if(e.which == 13) {
        e.preventDefault();
        this.blur();
      }
    });

    function nl2br (str) {
      return (str + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1<br>$2');
    }

    function copyToClipboard() {
      var image_url = ($(this).parents('.input-group').find('.image-url'))[0];
      image_url.setSelectionRange(0, image_url.value.length);
      document.execCommand("copy");
    }

    $('.image-url').click(selectText);
    $('.clipboard-btn').click(copyToClipboard);

    $('.share-facebook').click(function(){
      window.open(this.href,'targetWindow','toolbar=no,location=no,status=no,menubar=no,scrollbars=no,resizable=yes,width=560,height=350');
      return false;
    });

    $('.share-twitter').click(function(){
      window.open(this.href,'targetWindow','toolbar=no,location=no,status=no,menubar=no,scrollbars=no,resizable=yes,width=560,height=260');
      return false;
    });

    $('.delete-album-image').click(function(){
      if (!confirm('Are you sure?')) {
        return false;
      }
      var imageId = $(this).data('image-id');

      $.ajax({
        url: '/' + imageId,
        type: 'DELETE',
        processData: false,
        contentType: false,
        success: function (data) {
          $('#image-' + imageId).remove();
        }
      });

    });

    $('.delete-image').click(function() {
      if (!confirm('Are you sure?')) {
        return false;
      }
      var imageId = $(this).data('image-id');
      $.ajax({
        url: '/' + imageId,
        type: 'DELETE',
        processData: false,
        contentType: false,
        success: function (data) {
          window.location.href = '/my';
        }
      });
    });

    $('.hide-image').click(function() {
      var imageId = $(this).data('image-id');
      var selector = '#hide-image-' + imageId;
      var hiddenValue = $(selector).prop('checked')
      console.log(hiddenValue);

      var formData = new FormData();
      formData.append('hidden', hiddenValue ? '1' : '0');

      $.ajax({
        url: '/' + imageId,
        type: 'PUT',
        data: formData,
        processData: false,
        contentType: false
      });
    });

  });

}(window.jQuery);