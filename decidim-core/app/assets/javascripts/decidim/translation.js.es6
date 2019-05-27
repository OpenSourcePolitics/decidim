let translate = function (originalText, targetLang, callback) {
  $.ajax({
    url: "/api/translate",
    type: "GET",
    data: `target=${targetLang}&original=${originalText}`,
    dataType: "json",
    success: function (body) {
      callback([body.translations[0].detected_source_language, body.translations[0].text]);
    },
    error: function (body, status, error) {
      console.log(status + error);
    }
  });
};


$(() => {
  $(".translatable_btn").on("click", (event) => {
    event.preventDefault();

    const $item = $(event.target).parent();
    const $spinner = $item.children(".loading-spinner");
    const $btn = $item.children("span");

    let $title = null;
    let $body = null;

    const original = $item.data("original");
    const translated = $item.data("translated");
    const targetLang = $item.data("targetlang");
    const tranlatableType = $item.data("translatabletype");

    let translatable = $item.data("translatable");
    let originalTitle = $item.data("title");
    let originalBody = $item.data("body");

    switch (tranlatableType) {
    case "proposal-card":
      $title = $item.parent().parent().find(".card__title");
      $body = $item.parent().parent().find(".card__text--paragraph");
      break;
    default:
      console.log("No translatable type")
    }

    if (translatable) {
      $spinner.removeClass("loading-spinner--hidden");

      translate($title.text(), targetLang, (response) => {
        $item.data("title", $title.text());
        $title.text(response[1]);
      });

      translate($body.text(), targetLang, (response) => {
        $item.data("body", $body.text());
        $body.text(response[1]);

        $btn.text(translated);

        $spinner.addClass("loading-spinner--hidden");

        $item.data("translatable", false);
      });
    } else {
      $btn.text(original);
      $title.text(originalTitle);
      $body.text(originalBody);
      $item.data("translatable", true);
    }
  })
});

