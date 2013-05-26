$(function() {
 $("form").on("ajax:success", function(xhr, data, status) {
    $('#modifier_container').html(data);
  });
});