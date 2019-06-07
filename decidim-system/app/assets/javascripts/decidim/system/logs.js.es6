$(() => {
  $("#logs_search__reset").on("click", () => {
    event.preventDefault();
    $("#search_input").val("");
    $("form#logs_search__form").submit();
  })
});
