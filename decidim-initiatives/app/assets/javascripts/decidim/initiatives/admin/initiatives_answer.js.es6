(() => {
  // ANSWER DATE TOGGLE
  const $answerDateField = $("label[for='initiative_answer_date']").parent();
  const $initiativeSelect = $("#initiative_state");

  let getState = (element) => {
    // eslint-disable-next-line no-negated-condition
    if (element !== "published") {
      $answerDateField.show();
    } else {
      $answerDateField.hide();
    }
  };

  getState($initiativeSelect.find(":selected").val());
  $initiativeSelect.on("change", function () {
    // eslint-disable-next-line no-invalid-this
    getState(this.value);
  });
})();
