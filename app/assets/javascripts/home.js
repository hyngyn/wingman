$(function() {
 $("form").on("ajax:success", function(xhr, data, status) {
    $('.no_results').addClass("hidden");
    $('#modifier_container').html(data);
  });

  $("form").on("ajax:error", function(xhr, data, status) {
    $('.no_results').removeClass("hidden");
  });

  $("#new_search").on("click", function(){
    $('.no_results').addClass("hidden");
  });
});