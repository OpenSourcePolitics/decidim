// Switch order value when filtering by authors
// Defaults :
// any : sorts by Random
// myself : sorts by Most Recent

$(() => {
  const target = $("input[type='hidden']#order_filter");

  $("input[type='radio'][id^='filter_author_']").on("click", (event) => {
    const selectedAuthor = $(event.target)[0];

    switch (selectedAuthor.value) {
    case "any":
      target.val("random");
      break;
    case "myself":
      target.val("recent");
      break;
    default:
      return;
    }
  });
});
