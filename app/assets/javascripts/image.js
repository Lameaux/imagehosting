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
          $('span.' + entityName + '-' + propertyName + '-' + entityId).text(data[propertyName]);
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
      ['image', 'tags', 'input'],
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

      $(tagName + '.edit-' + entityName + '-' + propertyName).keypress(function(e) {
        if(e.which == 13) {
          e.preventDefault();
          triggerSaveChanges(this, entityName, propertyName, tagName);
        }
      });
    });


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


  });

}(window.jQuery);