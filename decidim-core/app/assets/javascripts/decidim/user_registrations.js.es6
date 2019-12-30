$(() => {
  const $userRegistrationForm = $("#register-form");
  const $userGroupFields = $userRegistrationForm.find(".user-group-fields");
  const inputSelector = "input[name='user[sign_up_as]']";
  const newsletterSelector = "input[type='checkbox'][name='user[newsletter]']";
  const $newsletterModal = $("#sign-up-newsletter-modal");
  const $formStepForwardButton = $(".form-step-forward-button");
  const $formStepBackButton = $(".form-step-back-button");
  const $formFirstStepFields = $("[form-step='1'] input");
  const $tosAgreement = $("#user_tos_agreement");
  const $mandatoryFormFirstStepFields = $formFirstStepFields.not("#user_newsletter").not("input[type ='hidden']").add($tosAgreement);
  const $userPassword = $("#user_password");
  const $userPasswordConfirmation = $("#user_password_confirmation");

  const $underageSelector = $("#underage_registration");
  const $statutoryRepresentativeEmailSelector = $("#statutory_representative_email");

  const emailSelectorToggle = () => {
    if ($underageSelector.is(":checked")) {
      $statutoryRepresentativeEmailSelector.removeClass("hide");
    } else {
      $statutoryRepresentativeEmailSelector.addClass("hide");
    }
  };

  if ($underageSelector.is(":checked")) {
    emailSelectorToggle();
  }

  $underageSelector.on("click", () => {
    emailSelectorToggle();
  });

  const setGroupFieldsVisibility = (value) => {
    if (value === "user") {
      $userGroupFields.hide();
    } else {
      $userGroupFields.show();
    }
  };

  const toggleFromSteps = () => {
    $("[form-step]").toggle();
    $("[form-active-step]").toggleClass("step--active");
  };

  const scrollToTop = () => {
    $("html, body").animate({
      scrollTop: $("main").offset().top
    }, 200);
  }

  const checkNewsletter = (check) => {
    $userRegistrationForm.find(newsletterSelector).prop("checked", check);
    $newsletterModal.data("continue", true);
    $newsletterModal.foundation("close");
    $userRegistrationForm.submit();
  };

  setGroupFieldsVisibility($userRegistrationForm.find(`${inputSelector}:checked`).val());

  $userRegistrationForm.on("change", inputSelector, (event) => {
    const value = event.target.value;

    setGroupFieldsVisibility(value);
  });

  $userRegistrationForm.on("submit", (event) => {
    const newsletterChecked = $userRegistrationForm.find(newsletterSelector);
    if (!$newsletterModal.data("continue")) {
      if (!newsletterChecked.prop("checked")) {
        event.preventDefault();
        $newsletterModal.foundation("open");
      }
    }
  });

  $newsletterModal.find(".check-newsletter").on("click", (event) => {
    checkNewsletter($(event.target).data("check"));
  });

  $formStepForwardButton.on("click", (event) => {
    event.preventDefault();

    scrollToTop();

    // validate only input elements from step 1
    $formFirstStepFields.each((index, element) => {
      $userRegistrationForm.foundation("validateInput", $(element));
    });

    if (!$userRegistrationForm.find("[data-invalid]:visible").length) {
      toggleFromSteps();
    }
  });

  $formStepBackButton.on("click", (event) => {
    event.preventDefault();

    scrollToTop();

    toggleFromSteps();
  });

  let fieldEmptyOrFalse = (element) => {
    if ($(element)[0].type === "checkbox") {
      return $(element)[0].checked === false;
    }
    return $(element).val().length === 0;
  };


  let filedMandatoryFormField = () => {
    return $mandatoryFormFirstStepFields.map((index, element) => {
      if (fieldEmptyOrFalse(element)) {
        return element;
      }
      return null
    });
  };

  let samePassword = () => {
    if ($userPassword.val() !== $userPasswordConfirmation.val()) {
      return $userPasswordConfirmation;
    }
    return null;
  };

  const checkMandatoryFormField = () => {
    return $.uniqueSort(filedMandatoryFormField().add(samePassword()))
  };

  const displayError = (element) => {
    $(element).addClass("is-invalid-input");
    $(element).parent().addClass("is-invalid-label");
    $(element).next("span").addClass("is-visible");
  };

  const hideError = (element) => {
    $(element).removeClass("is-invalid-input");
    $(element).parent().removeClass("is-invalid-label");
    $(element).next("span").removeClass("is-visible");
  };

  $userRegistrationForm.on("click load change input", () => {
    $mandatoryFormFirstStepFields.each((index, element) => {
      hideError(element);
    });

    checkMandatoryFormField().each((index, element) => {
      displayError(element);
    });

    if (checkMandatoryFormField().length === 0) {
      $formStepForwardButton.attr("disabled", false);
    } else {
      $formStepForwardButton.attr("disabled", true);
    }
  });
});
