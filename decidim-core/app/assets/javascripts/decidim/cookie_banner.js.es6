$(() => {

  let _createModalContainer = () => {
    return $(`<div class="large reveal reveal-modal" id="cookie_banner-modal" aria-hidden="true" role="dialog" aria-labelledby="cookie_banner-title" data-reveal>
                <div class="cookie_banner-modal-content"></div>
                <button class="close-button close-reveal-modal" data-close type="button" data-reveal-id="cookie_banner-modal"><span aria-hidden="true" aria-label="Close">&times;</span></button>
              </div>`);
  };
  let modal = _createModalContainer();
  modal.appendTo($("body"));

  $(document).on("click", "#cookie-banner__more-informations", (event) => {
    event.preventDefault();


    const $link = $(event.currentTarget);

    $.ajax({
      type: "get",
      url: $link.data("open-url"),
      success: (html) => {
        let modalContent = $(".cookie_banner-modal-content", modal);
        modalContent.html(html);
        modal.foundation("open");
        $("#cookie_banner-modal").attr("aria-hidden", "false");
      }
    });

  });

  $(document).on("change", ".switch-input", (event) => {
    const switchInput = $(event.currentTarget);
    const cookieName = switchInput.data("cc");

    if ($(`#deactivate_cc_${cookieName}`).is(":checked")) {
      $(`.activated_cc_message[data-cc="${cookieName}"]`).css("visibility", "visible");
    } else {
      $(`.activated_cc_message[data-cc="${cookieName}"]`).css("visibility", "hidden");
    }
  });
});
