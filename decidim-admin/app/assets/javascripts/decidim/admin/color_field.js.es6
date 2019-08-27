(() => {
  let hasColor = $("[name='category[has_color]']");
  let colorField = $("[name='category[color]']");

  let hasColorChecked = function () {
    return hasColor.is(":checked");
  };

  let colorFieldEnabled = function () {
    colorField.removeAttr("disabled");
    colorField.parent().show();
  };

  let colorFieldDisabled = function () {
    colorField.attr("disabled", "false");
    colorField.parent().hide();
  };

  // default state
  if (hasColorChecked()) {
    colorFieldEnabled();
  } else {
    colorFieldDisabled();
  }

  hasColor.on("change", function () {
    if (hasColorChecked()) {
      colorFieldEnabled();
    } else {
      colorFieldDisabled();
    }
  });
})();
