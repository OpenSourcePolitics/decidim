// = require ./progressFixed
// = require_self

$(() => {
  const $projects = $("#projects, #project");
  const $budgetSummaryTotal = $(".budget-summary__total");
  const $budgetSummaryProgress = $(".budget-summary__progressbox");
  const $limitExceedModal = $("#limit-excess");

  const totalBudget = parseInt($budgetSummaryTotal.attr("data-total-budget"), 10);
  const totalProjects = parseInt($budgetSummaryTotal.attr("data-total-projects"), 10);
  const votePerProject = $budgetSummaryTotal.attr("data-vote-per-project") === "true";
  const votePerBudget = $budgetSummaryTotal.attr("data-vote-per-budget") === "true";

  const cancelEvent = (event) => {
    event.stopPropagation();
    event.preventDefault();
  };

  $projects.on("click", ".budget--list__action", (event) => {
    const currentBudget = parseInt($budgetSummaryProgress.attr("data-current-budget"), 10);
    const currentProjects = parseInt($budgetSummaryProgress.attr("data-current-projects"), 10);
    const $currentTarget = $(event.currentTarget);
    const projectBudget = parseInt($currentTarget.attr("data-budget"), 10);
    if ($currentTarget.attr("data-add") && votePerProject && (currentProjects === totalProjects)) {
      $limitExceedModal.foundation("toggle");
      cancelEvent(event);
    } else if ($currentTarget.attr("disabled")) {
      cancelEvent(event);
    } else if ($currentTarget.attr("data-add") && votePerBudget && ((currentBudget + projectBudget) > totalBudget)) {
      $limitExceedModal.foundation("toggle");
    }
  });
});
