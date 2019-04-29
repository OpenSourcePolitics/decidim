(() => {
  const colorField = $("[name='category[color]']");
  const deleteColor = $("[name='category[delete_color]']");
  const parentField = $("[name='category[parent_id]']");

  let parentFieldEmpty = function () {
    return parentField.val() === "";
  };

  let deleteColorChecked = function () {
    return deleteColor.is(":checked");
  };

  let colorFieldEnabled = function () {
    colorField.removeAttr("disabled");
    colorField.parent().show();
  };

  let colorFieldDisabled = function () {
    colorField.attr("disabled", "false");
    colorField.parent().hide();
  };

  let deleteColorDisabled = function () {
    deleteColor.parent().hide();
  };

  let deleteColorEnabled = function () {
    deleteColor.parent().show();
  };

  if (!parentFieldEmpty()) {
    colorFieldDisabled();
    deleteColorDisabled();
  }

  parentField.on("change", function () {
    if (parentFieldEmpty()) {
      colorFieldEnabled();
      deleteColorEnabled();
    } else {
      colorFieldDisabled();
      deleteColorDisabled();
    }
  });

  deleteColor.on("change", function () {
    if (deleteColorChecked()) {
      colorFieldDisabled();
    } else {
      colorFieldEnabled();
    }
  });
})();
