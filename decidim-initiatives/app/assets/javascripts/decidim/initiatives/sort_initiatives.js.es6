// Switch order value when filtering by authors
// Defaults :
// any : sorts by Random
// myself : sorts by Most Recent

$(() => {
  const target = $("input[type='hidden']#order_filter");

  $("input[type='radio'][id^='filter_author_']").on("click", (event) => {
    const selectedAuthor = $(event.target)[0];

    if (selectedAuthor.value === "any") {
      target.val("random");
    } else if (selectedAuthor.value === "myself") {
      target.val("recent");
    }
  });
});
