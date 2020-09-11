(() => {
  // ANSWER DATE TOGGLE
  const $answerDateField = $("label[for='initiative_answer_date']").parent();
  const $initiativeSelect = $("#initiative_state");
  const $signatureEndDate = $("#initiative_signature_end_date");
  const currentSignatureEndDate = $signatureEndDate.val();

  let getState = (element) => {
    // eslint-disable-next-line no-negated-condition
    if (element !== "published") {
      $answerDateField.show();
    } else {
      $answerDateField.hide();
    }

    if (element === "classified") {
      $signatureEndDate.val(new Date().toLocaleDateString("fr-FR"));
    } else {
      $signatureEndDate.val(new Date(currentSignatureEndDate).toLocaleDateString("fr-FR"));
    }
  };

  getState($initiativeSelect.find(":selected").val());
  $initiativeSelect.on("change", function () {
    // eslint-disable-next-line no-invalid-this
    getState(this.value);
  });
})();
