// Here api autocomplete service
// This script allows to make requests to the here api autocomplete service following the user input

// When the api returns suggestions, a dropdown is displayed to the user to helping choosing an address
// It allows to avoid difference between address formatting

$(() => {
  const $inputAddress = $('#address_input #proposal_address')
  const apiKey = $inputAddress.data("hereApi")
  const apiUrl = "https://autocomplete.geocoder.ls.hereapi.com/6.2/suggest.json"
  const maxResultsPerRequest = 10 // set a response length limit. Set to false if you want all results
  const uniqueCountryCode = "FRA" // filter by country. Set to false if you want all results

  $inputAddress.on("input", () => {
      let params = '?' +
        'query=' +  encodeURI($inputAddress.val()) +
        '&apiKey=' + apiKey

      if (uniqueCountryCode !== false) {
        params += "&country=" + uniqueCountryCode
      }

      if (maxResultsPerRequest !== false) {
        params += "&maxresults=" + maxResultsPerRequest
      }

      const fillDatalist = (arrayOfSuggestions) => {
        for (const suggestion of arrayOfSuggestions) {
          switch (suggestion.matchLevel) {
            case 'houseNumber':
              var optionValue = suggestion.address.houseNumber + " " + suggestion.address.street + " " + suggestion.address.postalCode + " " + suggestion.address.city
              break
            case 'street':
              var optionValue = suggestion.address.street + " " + suggestion.address.postalCode + " " + suggestion.address.city
              break
            case 'city':
              var optionValue = suggestion.address.postalCode + " " + suggestion.address.city
              break
            case 'postalCode':
              var optionValue = refactorLabel(suggestion.label)
              break
            default:
              break
          }
          if (optionValue){
            $("#here_suggestions").append(new Option(suggestion.label, optionValue))
          }
        }
      }

      const hereApiRequest = url => {
        $.ajax({
          url: url,
          method: "GET"
        }).success(function( data ) {
          $("#here_suggestions").empty()
          if (Object.keys(data).length > 0) {
            fillDatalist(data.suggestions)
          }
        });
      }

      hereApiRequest(apiUrl + params)
  });
});

// Returns only postalCode and City from label
function refactorLabel(str) {
  const array = str.split(',');
  return array[array.length - 2] + array[array.length - 1]
}
