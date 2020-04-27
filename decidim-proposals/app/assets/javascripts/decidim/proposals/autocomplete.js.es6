// Here api autocomplete service
// This script allows to make requests to the here api autocomplete service following the user input

// When the api returns suggestions, a dropdown is displayed to the user to helping choosing an address
// It allows to avoid difference between address formatting

$(() => {
  const $inputAddress = $('#address_input #proposal_address')
  const apiKey = $inputAddress.data("hereApi")
  const apiUrl = "https://autocomplete.geocoder.ls.hereapi.com/6.2/suggest.json"
  const minLengthForSearch = 10;
  const maxResultsPerRequest = 10;

  $inputAddress.on("input", () => {
    if ($inputAddress.val().length > minLengthForSearch) {
      let params = '?' +
        'query=' +  encodeURI($inputAddress.val()) +
        '&maxresults=' + maxResultsPerRequest +
        '&apiKey=' + apiKey;

      $.ajax({
        url: apiUrl + params,
        method: "GET"
      }).success(function( data ) {
        for (const suggestion of data.suggestions) {
          if (suggestion.countryCode == "FRA") {
            if (suggestion.matchLevel == "houseNumber") {
              console.log(suggestion.address.houseNumber + " " + suggestion.address.street + " " + suggestion.address.postalCode + " " + suggestion.address.city)
            } else {
              console.log(suggestion.address.street + " " + suggestion.address.postalCode + " " + suggestion.address.city)
            }
          }
        }
      });
    }
  });
});
