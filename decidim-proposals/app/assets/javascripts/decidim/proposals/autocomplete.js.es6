// Here api autocomplete service
// This script allows to make requests to the here api autocomplete service following the user input

// When the api returns suggestions, a dropdown is displayed to the user to helping choosing an address
// It allows to avoid difference between address formatting

$(() => {
  const $inputAddress = $("#address_input #proposal_address")
  const $datalistSuggestions = $("#here_suggestions")
  const apiKey = $datalistSuggestions.data("hereApi")
  const apiUrl = "https://autocomplete.geocoder.ls.hereapi.com/6.2/suggest.json"
  // set a minimum input length to submit request. Set to false if you do not want minimum length
  const minLenInput = 5
  // set a response length limit. Set to false if you want all results
  const maxResultsPerRequest = 10
  // filter by country. Set to false if you want all results
  const uniqueCountryCode = "FRA"

  $inputAddress.on("input", () => {
    const userInput = $.trim($inputAddress.val())

    const isSameAddress = (input) => {
      return $(`#here_suggestions option[value="${input}"]`).length > 0
    }

    if (isSameAddress(userInput)) {
      return
    }

    let params = `?query=${encodeURI(userInput)}&apiKey=${apiKey}`

    if (uniqueCountryCode !== false) {
      params += `&country=${uniqueCountryCode}`
    }

    if (maxResultsPerRequest !== false) {
      params += `&maxresults=${maxResultsPerRequest}`
    }

    // Allows to reformat the here api response label for the concerned suggestion
    const refactorLabel = (str) => {
      const array = str.split(",");
      return array[array.length - 2] + array[array.length - 1]
    }

    const fillDatalist = (arrayOfSuggestions) => {
      let optionValue = ""
      for (const suggestion of arrayOfSuggestions) {
        switch (suggestion.matchLevel) {
        case "houseNumber":
          optionValue = `${suggestion.address.houseNumber} ${suggestion.address.street} ${suggestion.address.postalCode} ${suggestion.address.city}`
          break
        case "street":
          optionValue = `${suggestion.address.street} ${suggestion.address.postalCode} ${suggestion.address.city}`
          break
        case "city":
          optionValue = `${suggestion.address.postalCode} ${suggestion.address.city}`
          break
        case "postalCode":
          optionValue = refactorLabel(suggestion.label)
          break
        default:
          break
        }
        if (optionValue) {
          $datalistSuggestions.append(new Option(suggestion.label, optionValue))
        }
      }
    }

    const hereApiRequest = (url) => {
      $.ajax({
        url: url,
        method: "GET"
      }).success(function(data) {
        $("#here_suggestions").empty()
        if (Object.keys(data).length > 0) {
          fillDatalist(data.suggestions)
        }
      });
    }

    if (userInput.length > minLenInput || minLenInput === false) {
      hereApiRequest(apiUrl + params)
    }
  });
});
