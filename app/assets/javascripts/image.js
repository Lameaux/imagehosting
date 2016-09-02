!function ($) {
  $(function () {

    function showEditor(imageId, propertyName, tagName) {
      $(tagName + '.image-' + propertyName + '-' + imageId).removeClass('hidden');
      $(tagName + '.image-' + propertyName + '-' + imageId).focus();
      $('span.image-' + propertyName + '-' + imageId).addClass('hidden');
      $('button.image-' + propertyName + '-' + imageId).addClass('hidden');
    }

    function saveChanges(imageId, propertyName, propertyValue, tagName) {
      $('span.image-' + propertyName + '-' + imageId).removeClass('hidden');
      $('button.image-' + propertyName + '-' + imageId).removeClass('hidden');
      $(tagName + '.image-' + propertyName + '-' + imageId).addClass('hidden');

      var formData = new FormData();
      formData.append(propertyName, propertyValue);

      $.ajax({
        url : '/' + imageId,
        type : 'PUT',
        data : formData,
        processData: false,
        contentType: false,
        success : function(data) {
          $('span.image-' + propertyName + '-' + imageId).text(data[propertyName]);
        }
      });
    }

    function triggerSaveChanges(that, propertyName, tagName) {
      var imageId = $(that).data('image-id');
      var propertyValue = $(that).val();
      saveChanges(imageId, propertyName, propertyValue, tagName);
    }

    [
      ['title', 'input'],
      ['description', 'textarea'],
      ['tags', 'input'],
    ].forEach(function(element, index, array){
      var propertyName = element[0];
      var tagName = element[1];
      $('button.edit-image-' + propertyName).click(function(){
        var imageId = $(this).data('image-id');
        showEditor(imageId, propertyName, tagName);
      });

      $(tagName + '.edit-image-' + propertyName).focusout(function(){
        triggerSaveChanges(this, propertyName, tagName);
      });

      $(tagName + '.edit-image-' + propertyName).keypress(function(e) {
        if(e.which == 13) {
          triggerSaveChanges(this, propertyName, tagName);
        }
      });
    });




  });

}(window.jQuery);