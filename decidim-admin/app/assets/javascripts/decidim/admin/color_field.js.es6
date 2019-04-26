(() => {
  const colorField = $("[name='category[color]']");
  const parentField = $("[name='category[parent_id]']");

  let parentFieldEmpty = function () {
    return parentField.val() === "";
  };

  let colorFieldEnabled = function () {
    colorField.removeAttr("disabled");
  };

  let colorFieldDisabled = function () {
    colorField.attr("disabled", "false");
  };

  if (!parentFieldEmpty()) {
    colorFieldDisabled();
  }

  parentField.on("change", function () {
    if (parentFieldEmpty()) {
      colorFieldEnabled();
    } else {
      colorFieldDisabled();
    }
  });
})();
