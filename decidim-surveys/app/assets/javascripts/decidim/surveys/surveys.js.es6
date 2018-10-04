// = require ./option_attached_inputs.component
// = require ./create_sortable_list.component


((exports) => {
  const {createOptionAttachedInputs, createSortableList} = exports.Decidim;

  $(".radio-button-collection, .check-box-collection").each((idx, el) => {
    createOptionAttachedInputs({
      wrapperField: $(el),
      controllerFieldSelector: "input[type=radio], input[type=checkbox]",
      dependentInputSelector: "input[type=text], input[type=hidden]"
    });
  });

  createSortableList({ class: "sortable-check-box-collection", index: "sortable-index", choice: "sortable-choice" })
})(window);
