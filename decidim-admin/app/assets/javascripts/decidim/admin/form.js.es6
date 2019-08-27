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

  $targetFieldsets.each((_idx, fieldset) => {
    let $supports = $(fieldset).find("input[id*='votes_enabled']");
    let $votes = $(fieldset).find("input[id*='votes_weight_enabled']");

    disableClick($supports, $votes);
    disableClick($votes, $supports);
    switchDisabling($supports, $votes);
    switchDisabling($votes, $supports);
  })

  // BUDGET
  const $totalBudget = $("input#component_settings_total_budget");
  const $perBudget = $("input#component_settings_vote_per_budget");
  const $perProject = $("input#component_settings_vote_per_project");
  const $perBudgetFields = $("input.per-budget-rule");
  const $perProjectFields = $("input.per-project-rule");

  $perBudgetFields.add($totalBudget).each((_idx, field) => {
    disableClick($(field), $perProject);
    switchDisabling($perProject, $(field));
  })

  $perProjectFields.each((_idx, field) => {
    disableClick($(field), $perBudget);
    switchDisabling($perBudget, $(field));
  })

  // BUDGET VALIDATIONS
  const $perCategory = $("input#component_settings_vote_per_category");
  const componentProjects = parseInt($(".voting-rules-settings").attr("data-component-projects"), 10);
  const $totalProjects = $("input#component_settings_total_projects");
  const $perCategoryFields = $("input.per-category-rule");
  const $submitButton = $("button[type=submit]");
  const $votingRulesModal = $("#voting-rules-modal");

  const noVotingRuleIsChecked = () => {
    return !$perBudget.is(":checked") && !$perProject.is(":checked")
  }

  const totalProjectsExceedsComponentProjects = () => {
    if (!$perProject.is(":checked")) return false

    let totalProjects = parseInt($totalProjects.val(), 10);

    return totalProjects > componentProjects
  }

  const projectsPerCategoryExceedsComponentProjects = () => {
    if (!$perCategory.is(":checked")) return false

    let totalProjectsPerCategory = 0;

    $perCategoryFields.each((_idx, field) => {
      totalProjectsPerCategory += parseInt($(field).val(), 10);
    });

    return totalProjectsPerCategory > componentProjects
  }

  $submitButton.click((event) => {
    if (
      noVotingRuleIsChecked() ||
      totalProjectsExceedsComponentProjects() ||
      projectsPerCategoryExceedsComponentProjects()
    ) {
      $votingRulesModal.foundation("toggle");
      event.preventDefault();
      event.stopPropagation();
    }
  })
});
