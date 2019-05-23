let translated_title = function (response) {

};

let translated_body = function (response) {
};

let translate = function (original_text, target_lang, callback) {
  $.ajax({
    url: "/api/translate",
    type: "GET",
    data: `target=${target_lang}&original=${original_text}`,
    dataType: "json",
    success: function (body, status) {
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

    $title.addClass("debug");
    $body.addClass("debug");

    $spinner.removeClass("loading-spinner--hidden");
    $.when(
      translate($title.text(), targetLang, translated_title()),
      translate($body.text(), targetLang, translated_body())
    ).then(
      $spinner.addClass("loading-spinner--hidden")
    )
    ;
    return null;
  })
});

