const findGetParameter = (parameterName) => {
  let result = null;
  let tmp = [];

  location.search.substr(1).split("&").forEach(function (item) {
    tmp = item.split("=");
    if (tmp[0] === parameterName) {
      result = decodeURIComponent(tmp[1])
    }
  });
  return result;
};


$(() => {
  if (findGetParameter("auto_refresh") === "true") {
    setTimeout(() => {
      window.location.reload()
    }, 5000);
  }

  $("#logs_search__reset").on("click", () => {
    event.preventDefault();
    $("#search_input").val("");
    $("form#logs_search__form").submit();
  })
});
