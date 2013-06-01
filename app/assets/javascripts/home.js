// home.js
// handles toggling showing and hiding error messages/value prop during search

$(function() {
 $("form").on("ajax:success", function(xhr, data, status) {
    $('.no_results').addClass("hidden");
    $('#modifier_container').html(data);
  });

  $("form").on("ajax:error", function(xhr, data, status) {
    $('.no_results').removeClass("hidden");
  });

  $("form").on("ajax:before", function(xhr, data, status) {
    $(".btn-primary").attr("disabled", true);
  });

  $("form").on("ajax:complete", function(xhr, data, status) {
    $(".btn-primary").attr("disabled", false);
  });

  $("#new_search").on("click", function(){
    $('.no_results').addClass("hidden");
  });

  $(".btn-primary").on("click", function(){
    $('.no_results').addClass("hidden");
  });

  $("#start_date").datepicker();
  $("#end_date").datepicker();
});