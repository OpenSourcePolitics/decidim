let translate = function (original_text, target_lang, callback, spinner) {
  $.ajax({
    url: "/api/translate",
    type: "GET",
    data: `target=${target_lang}&original=${original_text}`,
    dataType: "json",
    success: function (body, status) {
      spinner.addClass("loading-spinner--hidden");
      callback([body.translations[0].detected_source_language, body.translations[0].text]);
    },
    error: function (body, status, error) {
      spinner.addClass("loading-spinner--hidden")
      console.log(status + error);
    }
  });
};


$(() => {
  $(".translatable_btn").on("click", (event) => {
    event.preventDefault();

    const $item = $(event.target).parent();
    const $spinner = $item.children(".loading-spinner");
    const tranlatableType = $item.data("translatabletype");
    const targetLang = $item.data("targetlang");
    let $title = null;
    let $body = null;

    switch (tranlatableType) {
    case "proposal-card":
      $title = $item.parent().parent().find(".card__title");
      $body = $item.parent().parent().find(".card__text--paragraph");
      break;
    default:
      console.log("No translatable type")
    }

    $spinner.removeClass("loading-spinner--hidden");

    translate($title.text(), targetLang, (response) => {
      $title.text(response[1])
    }, $spinner);
    translate($body.text(), targetLang, (response) => {
      $body.text(response[1])
    }, $spinner);

    return null;
  })
});

