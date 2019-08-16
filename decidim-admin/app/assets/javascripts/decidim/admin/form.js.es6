$(() => {
  const disableClick = (check1, check2) => {
    check1.prop("disabled", check2.is(":checked"));
  }

  const switchDisabling = (check1, check2) => {
    check1.click(() => {
      check2.prop("disabled", check1.is(":checked"));
    })
  }

  // PROPOSAL
  const $stepSettingsFieldsets = $("fieldset.step-settings").find("fieldset");
  const $defaultStepSettingsFieldset = $("fieldset.default-step-settings");
  const $targetFieldsets = $stepSettingsFieldsets.add($defaultStepSettingsFieldset);

  $targetFieldsets.each((index, fieldset) => {
    let $supports = $(fieldset).find("input[id*='votes_enabled']");
    let $votes = $(fieldset).find("input[id*='votes_weight_enabled']");

    disableClick($supports, $votes);
    disableClick($votes, $supports);
    switchDisabling($supports, $votes);
    switchDisabling($votes, $supports);
  })

  // BUDGET
  const $totalBudget = $('input#component_settings_total_budget');
  const $perBudget = $('input#component_settings_vote_per_budget');
  const $perProject = $('input#component_settings_vote_per_project');
  const $perBudgetFields = $("input.per-budget-rule");
  const $perProjectFields = $("input.per-project-rule");

  $perBudgetFields.add($totalBudget).each((index, field) => {
    disableClick($(field), $perProject);
    switchDisabling($perProject, $(field));
  })

  $perProjectFields.each((index, field) => {
    disableClick($(field), $perBudget);
    switchDisabling($perBudget, $(field));
  })
});
